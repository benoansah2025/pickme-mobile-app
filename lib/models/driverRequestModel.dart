import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/config/mapFunction.dart';

import 'driverDetailsModel.dart';

class DriverRequestModel {
  CurrentRideDetails? currentRideDetails;
  CurrentTripDetails? currentTripDetails;
  String? status;
  String? actionDate;
  int? requestTimeoutSec;

  DriverRequestModel({
    this.currentRideDetails,
    this.currentTripDetails,
    this.status,
    this.actionDate,
    this.requestTimeoutSec,
  });

  DriverRequestModel.fromJson(Map<dynamic, dynamic> json) {
    currentRideDetails =
        json['currentRideDetails'] != null ? new CurrentRideDetails.fromJson(json['currentRideDetails']) : null;
    currentTripDetails =
        json['currentTripDetails'] != null ? new CurrentTripDetails.fromJson(json['currentTripDetails']) : null;
    status = json['status'];
    actionDate = json["actionDate"];
    requestTimeoutSec = json["requestTimeoutSec"] ?? 15; // default request timeout is 15 seconds
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentRideDetails != null) {
      data['currentRideDetails'] = currentRideDetails!.toJson();
    }
    if (currentTripDetails != null) {
      data['currentTripDetails'] = currentTripDetails!.toJson();
    }
    data['status'] = status;
    return data;
  }

  Future<void> driverCompleteRequest(Position currentLocation) async {
    if (currentRideDetails?.riderPosition != null && currentRideDetails?.destinationPosition != null) {
      GeoPoint currentGeoPoint = GeoPoint(currentLocation.latitude, currentLocation.longitude);
      GeoPoint riderGeoPoint = GeoPoint(
        currentRideDetails!.riderPosition!.latitude,
        currentRideDetails!.riderPosition!.longitude,
      );

      // rider
      // Compute the distance between the current location and the destination
      final double riderDistanceInKm = GeoFirePoint(currentGeoPoint).distanceBetweenInKm(geopoint: riderGeoPoint);
      currentRideDetails!.riderDistanceInKm = riderDistanceInKm;
      currentRideDetails!.riderDistanceInM = riderDistanceInKm * 1000;

      List<LatLng> locations = [
        LatLng(currentLocation.latitude, currentLocation.longitude),
        LatLng(
          currentRideDetails!.riderPosition!.latitude,
          currentRideDetails!.riderPosition!.longitude,
        ),
      ];

      final riderDuration = await getDurationInSeconds(locations);
      currentRideDetails!.riderDuration = riderDuration;

      // destination
      final double destinationDistanceInKm = GeoFirePoint(currentRideDetails!.destinationPosition!).distanceBetweenInKm(
        geopoint: riderGeoPoint,
      );
      currentRideDetails!.destinationDistanceInKm = destinationDistanceInKm;
      currentRideDetails!.destinationDistanceInM = destinationDistanceInKm * 1000;

      List<LatLng> desLocations = [
        LatLng(
          currentRideDetails!.riderPosition!.latitude,
          currentRideDetails!.riderPosition!.longitude,
        ),
        LatLng(
          currentRideDetails!.destinationPosition!.latitude,
          currentRideDetails!.destinationPosition!.longitude,
        ),
      ];

      final destinationDuration = await getDurationInSeconds(desLocations);
      currentRideDetails!.destinationDuration = destinationDuration;
    } else {
      log("Rider position or destination position is not available.");
    }
  }
}

class CurrentRideDetails {
  dynamic discountPercentage;
  String? riderId;
  String? driverId;
  String? destinationInText;
  String? riderPhone;
  String? riderPicture;
  String? riderLocationInText;
  String? riderNearbyLocation;
  String? riderFirebaseKey;
  GeoPoint? riderPosition;
  double? riderDistanceInM;
  double? riderDistanceInKm;
  int? riderDuration;
  String? paymentMethod;
  GeoPoint? destinationPosition;
  String? destinationGeofenceId;
  double? destinationDistanceInM;
  double? destinationDistanceInKm;
  String? promoCode;
  String? riderName;
  int? destinationDuration;
  List<StopStut>? stops;
  String? serviceType;

  CurrentRideDetails({
    this.discountPercentage,
    this.riderId,
    this.destinationInText,
    this.riderPhone,
    this.riderLocationInText,
    this.riderFirebaseKey,
    this.riderPosition,
    this.paymentMethod,
    this.destinationPosition,
    this.promoCode,
    this.riderName,
    this.riderPicture,
    this.riderDistanceInKm,
    this.riderDistanceInM,
    this.destinationDistanceInKm,
    this.destinationDistanceInM,
    this.destinationDuration,
    this.riderDuration,
    this.driverId,
    this.stops,
    this.serviceType,
    this.destinationGeofenceId,
    this.riderNearbyLocation
  });

  CurrentRideDetails.fromJson(Map<String, dynamic> json) {
    discountPercentage = double.parse(json['discountPercentage'].toString());
    riderId = json['riderId'];
    destinationInText = json['destinationInText'];
    riderPhone = json['riderPhone'];
    riderLocationInText = json['riderLocationInText'];
    riderNearbyLocation = json['riderNearbyLocation'] ?? "";
    riderFirebaseKey = json['riderFirebaseKey'];
    riderPosition = json['riderPosition'];
    riderPicture = json['riderPicture'] ?? "";
    paymentMethod = json['paymentMethod'];
    destinationPosition = json['destinationPosition'];
    promoCode = json['promoCode'];
    riderName = json['riderName'];
    driverId = json['driverId'];
    
    if (json["stops"] != null) {
      stops = <StopStut>[];
      json["stops"].forEach((v) {
        stops!.add(StopStut.fromJson(v));
      });
    }

    serviceType = json["serviceType"] ?? "";
    destinationGeofenceId = json["destinationGeofenceId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discountPercentage'] = discountPercentage;
    data['riderId'] = riderId;
    data['destinationInText'] = destinationInText;
    data['riderPhone'] = riderPhone;
    data['riderLocationInText'] = riderLocationInText;
    data['riderNearbyLocation'] = riderNearbyLocation;
    data['riderFirebaseKey'] = riderFirebaseKey;
    data['riderPosition'] = riderPosition;
    data['riderPicture'] = riderPicture;
    data['paymentMethod'] = paymentMethod;
    data['destinationPosition'] = destinationPosition;
    data['promoCode'] = promoCode;
    data['riderName'] = riderName;
    data['driverId'] = driverId;
    return data;
  }
}

class CurrentTripDetails {
  String? tripId;
  String? estimatedTotalAmount;
  String? vehicleTypeBaseFare;

  CurrentTripDetails({
    this.tripId,
    this.estimatedTotalAmount,
    this.vehicleTypeBaseFare,
  });

  CurrentTripDetails.fromJson(Map<String, dynamic> json) {
    tripId = json['tripId'];
    estimatedTotalAmount = json["estimatedTotalAmount"] ?? "N/A";
    vehicleTypeBaseFare = json["vehicleTypeBaseFare"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tripId'] = tripId;
    return data;
  }
}
