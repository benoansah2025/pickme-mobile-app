import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';

class RecordLiveLocationProvider {
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _distanceThreshold = 10.0; // Initial threshold in meters
  final List<Position> _batchedPositions = [];
  final double _speedThreshold = 0.5; // Speed in m/s to filter out noise

  final FirebaseService _firebaseService = new FirebaseService();

  void record({
    required StartStop action,
    ServicePurpose? purpose,
  }) {
    if (action == StartStop.start) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
      ).listen((Position position) async {
        debugPrint(action.toString());
        
        if (_lastPosition == null) {
          _lastPosition = position;
        } else {
          double distanceInMeters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          double speed = position.speed; // Speed in m/s
          // log("user speed => $speed, distance => $distanceInMeters");

          // Ignore positions with very low speed (likely noise)
          if (speed < _speedThreshold) return;

          // Set threshold based on speed ranges
          if (speed < 3) {
            _distanceThreshold = 5.0; // Fine-grained updates at walking speed
          } else if (speed >= 3 && speed < 10) {
            _distanceThreshold = 10.0; // Moderate threshold for biking speeds
          } else if (speed >= 10) {
            _distanceThreshold = 20.0; // Larger threshold for driving speeds
          }

          if (distanceInMeters >= _distanceThreshold) {
            _lastPosition = position;
            _batchedPositions.add(position);

            // Handle the batched update
            await _processBatchedUpdates(purpose: purpose);
          }
        }
      });
    } else if (action == StartStop.stop) {
      _positionStream?.cancel();
      _positionStream = null;
    }
    debugPrint(action.toString());
  }

  Future<void> _processBatchedUpdates({required ServicePurpose? purpose}) async {
    if (_batchedPositions.isNotEmpty) {
      log("Batched positions: $_batchedPositions");
      // Send to server or update UI here

      final GeoFirePoint geoFirePoint = GeoFirePoint(
        GeoPoint(
          _batchedPositions.first.latitude,
          _batchedPositions.first.longitude,
        ),
      );

      Map<String, dynamic> reqBody = {
        "geohash": geoFirePoint.geohash,
        "lat": _batchedPositions.first.latitude,
        "log": _batchedPositions.first.longitude,
        "heading": _batchedPositions.first.heading,
        "userId": userModel!.data!.user!.userid,
      };
      if (purpose == null) {
        // record worker live location to driver_location
        await _firebaseService.recordWorkerLiveLocation(reqBody);
      } else {
        // record worker live location to appropriate service being rendered
      }

      _batchedPositions.clear(); // Clear after processing
    }
  }

  void dispose() {
    _positionStream?.cancel();
  }
}
