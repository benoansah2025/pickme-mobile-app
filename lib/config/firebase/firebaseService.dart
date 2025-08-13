import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pickme_mobile/config/checkConnection.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/models/driverDetailsModel.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/feeModel.dart';
import 'package:pickme_mobile/models/notificationsModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'firebaseUtils.dart';

abstract class _BaseDatabase {
  Future<Response> goOnline(Map<String, dynamic> reqBody);
  Future<Response> goOffline(Map<String, dynamic> reqBody);
  Stream<Response> searchRideStream(Map<String, dynamic> reqBody);
  Stream<DriverDetailsModel?> getDriverLocationDetails(String driverId);
  Stream<Response> bookRideStream(Map<String, dynamic> reqBody);
  Future<Response> cancelTrip(Map<String, dynamic> reqBody);
  Future<void> recordWorkerLiveLocation(Map<String, dynamic> reqBody);
  Future<Response> acceptRide(Map<String, dynamic> reqBody);
  Stream<DriverRequestModel?> getDriverRequest(String driverId, Position currentLocation);
  Future<Response> arriveAtPickup(Map<String, dynamic> reqBody);
  Future<Response> startTrip(Map<String, dynamic> reqBody);
  Future<Response> tripEnded(Map<String, dynamic> reqBody, FeeModel feeModel);
  Future<Response> tripCompleted(Map<String, dynamic> reqBody);
  Future<TripDetailsModel?> tripDetails(String tripId);
  Future<TripDetailsModel?> userOnGoingTrip(String userId);
  Stream<TripDetailsModel?> userTripDetailsStream(String userId);
  Future<Response> saveWorkerServices(Map<String, dynamic> reqBody);
  Future<List<String>?> getWorkerServices(String userId);
  Future<List<Map>?> getEmergency(String userId);
  Future<void> reportErrors(String error, String stackTrace);
  Future<Response> saveEmergency(Map<String, dynamic> reqBody);
  Future<Response> saveWorkerRadius(Map<String, dynamic> reqBody);
  Future<Response> saveUserToken(Map<String, dynamic> reqBody);
  Stream<String?> userTokenStream(String userId);
  Future<NotificationsModel?> getNotifications(String userId);
  Future<Response> markNotificationAsRead(String userId, String notificationId);
  Future<Response> updateOnGoingTripWithPolylines(String driverId, String points);
}

class FirebaseService implements _BaseDatabase {
  // Collection References
  final CollectionReference _driversLocationCollection = FirebaseFirestore.instance.collection("driver_locations");
  final CollectionReference _driversCollection = FirebaseFirestore.instance.collection("drivers");
  final CollectionReference _tripsCollection = FirebaseFirestore.instance.collection("trip_logs");
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection("Users");
  final CollectionReference _errorLogsCollection = FirebaseFirestore.instance.collection("error_logs");

  Future<String> getWorkerStatus(String workerId) async {
    // check if a drvier exists in the driver collection
    final DocumentSnapshot driverDoc = await _driversLocationCollection.doc(workerId).get();

    if (driverDoc.exists) {
      final driverData = driverDoc.data() as Map;
      final String status = driverData["status"];
      return status;
    } else {
      return "INACTIVE";
    }
  }

  @override
  Future<Response> goOnline(Map<String, dynamic> reqBody) async {
    bool connection = await checkConnection();
    if (!connection) {
      return Response(
        jsonEncode({
          "ok": false,
          "msg": "No internet connection",
        }),
        500,
      );
    }
    try {
      final String driverId = reqBody["data"]["driverId"];

      // check if a drvier exists in the driver collection
      final DocumentSnapshot driverDoc = await _driversLocationCollection.doc(driverId).get();

      if (driverDoc.exists) {
        final driverData = driverDoc.data() as Map;
        final String status = driverData["status"];

        if (!["ONHOLD", "INACTIVE"].contains(status)) {
          return Response(
            jsonEncode({
              "ok": false,
              "msg": status == "TRIP-STARTED" || status == "RIDE-ACCEPTED"
                  ? "Trip Started. Restart App To Continue."
                  : "Already Online",
            }),
            500,
          );
        }

        final Map<String, dynamic> driverDataToUpdate = {
          "go_live_time": DateTime.now(),
          "position": {
            "geohash": reqBody["position"]["geohash"],
            "geopoint": GeoPoint(
              reqBody["position"]["geopoint"][0] as double,
              reqBody["position"]["geopoint"][1] as double,
            ),
            "heading": reqBody["position"]["heading"],
          },
          "status": reqBody["status"],
          "currentRideDetails": {},
          "data": reqBody["data"],
        };

        await _driversLocationCollection.doc(driverId).update(driverDataToUpdate);

        return Response(
          jsonEncode({
            "ok": true,
            "msg": "Driver is live.",
          }),
          200,
        );
      } else {
        final Map<String, dynamic> driverDataToCreate = {
          "createdat": DateTime.now(),
          "go_live_time": DateTime.now(),
          "position": {
            "geohash": reqBody["position"]["geohash"],
            "geopoint": GeoPoint(
              reqBody["position"]["geopoint"][0] as double,
              reqBody["position"]["geopoint"][1] as double,
            ),
          },
          "status": reqBody["status"],
          "currentRideDetails": {},
          "data": reqBody["data"],
        };

        await _driversLocationCollection.doc(driverId).set(driverDataToCreate);

        return Response(
          jsonEncode({
            "ok": true,
            "msg": "Driver is live.",
          }),
          200,
        );
      }
    } catch (error, stackTrace) {
      log("Error in goOnline: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured while going live",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> goOffline(Map<String, dynamic> reqBody) async {
    bool connection = await checkConnection();
    if (!connection) {
      return Response(
        jsonEncode({
          "ok": false,
          "msg": "No internet connection",
        }),
        500,
      );
    }
    try {
      final String driverId = reqBody["data"]["driverId"];

      //find the driver document in the driver collection
      final DocumentSnapshot driverDoc = await _driversLocationCollection.doc(driverId).get();

      if (!driverDoc.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found",
          }),
          500,
        );
      }

      final driverData = driverDoc.data() as Map;

      if (driverData["status"] != "ACTIVE") {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Going offline failed. Driver is not active.",
          }),
          500,
        );
      }

      final Map<String, dynamic> driverDataToUpdate = {
        "go_live_time": "",
        "status": "INACTIVE",
        "currentRideDetails": {},
        "currentTripDetails": {},
      };

      await _driversLocationCollection.doc(driverId).update(driverDataToUpdate);

      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Driver is offline.",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in goOffline: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured while going offline",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Stream<DriverDetailsModel?> getDriverLocationDetails(String driverId) async* {
    //find the driver location document in the driver collection
    await for (var driverDoc in _driversLocationCollection.doc(driverId).snapshots()) {
      if (!driverDoc.exists) {
        DriverDetailsModel data = DriverDetailsModel.fromJson({});
        yield data;
      } else {
        final driverData = driverDoc.data() as Map;
        DriverDetailsModel data = DriverDetailsModel.fromJson(driverData);
        yield data;
      }
    }
  }

  @override
  Stream<Response> searchRideStream(Map<String, dynamic> reqBody) async* {
    try {
      log("Starting searchRideStream");

      List<String> onHoldDriverIdList = reqBody["onHoldDriverIds"] ?? [];
      String vehicleTypeId = reqBody["vehicleTypeId"] ?? "";

      // center point for the search radius using the latitude and longitude values
      final GeoFirePoint center = GeoFirePoint(GeoPoint(reqBody['latitude'], reqBody['longitude']));

      // convert estimated distance to kilometer
      const double maxRadiusInKm = 5.0; //5 km

      final driverDoc = await _driversLocationCollection.get();
      final allData = driverDoc.docs.map((doc) => doc.data()).toList();
      log("$allData");

      // perform the query
      final geoRef = GeoCollectionReference(_driversLocationCollection);

      // Initialize an array to store driver Ids and their corresponding distrances
      // Map to store drivers with their IDs as keys
      final Map<String, Map<String, dynamic>> driversMap = {};
      await for (var snapshots in geoRef.subscribeWithin(
        center: center,
        radiusInKm: maxRadiusInKm,
        field: "position",
        queryBuilder: (Query query) => query.where("status", isEqualTo: "ACTIVE"),
        geopointFrom: (Object? data) => (data as Map<String, dynamic>)["position"]["geopoint"] as GeoPoint,
        strictMode: true,
      )) {
        log("Received snapshot: ${snapshots.length} drivers found");

        for (final doc in snapshots) {
          log("Processing driver document: ${doc.id}");

          // Skip drivers that are on hold
          if (onHoldDriverIdList.contains(doc.id)) {
            log("Driver ${doc.id} is on hold, skipping...");
            continue;
          }

          final driverData = doc.data() as Map;
          DriverDetailsModel data = DriverDetailsModel.fromJson(driverData);

          // filtering vehicle type
          if (vehicleTypeId != "" && vehicleTypeId != data.data!.vehicleType) {
            log("Driver ${doc.id} car not match, skipping...");
            continue;
          }

          // Retrieve the latitude and longitude
          final double lat = data.position!.geopoint!.latitude;
          final double long = data.position!.geopoint!.longitude;
          final double heading = data.position!.heading!;

          // Get the driver's specific search radius
          final double driverRadiusInKm = data.radiusInM! / 1000; // Default to 4.0 if not specified

          // calculate distance between driver and center point
          final double distanceInKm = center.distanceBetweenInKm(geopoint: GeoPoint(lat, long));
          final double distanceInM = distanceInKm * 1000;

          // check if the distance is within the specified radius
          if (distanceInKm <= driverRadiusInKm) {
            List<LatLng> locations = [
              LatLng(lat, long),
              LatLng(reqBody["latitude"], reqBody["longitude"]),
            ];

            final duration = await getDurationInSeconds(locations);

            // Update or add the driver's information in the map
            driversMap[doc.id] = {
              "driverId": doc.id,
              "distanceInKm": distanceInKm,
              "distanceInM": distanceInM,
              "duration": duration,
              "latitute": lat,
              "longitude": long,
              "heading": heading,
              if (reqBody["totalFee"] != null) ...{
                "totalFee": reqBody["totalFee"],
                "vehicleTypeBaseFare": reqBody["vehicleTypeBaseFare"],
              },
              "data": driverData["data"],
            };
          }
        }
        // Convert the map values to a list
        List<Map<String, dynamic>> uniqueDrivers = driversMap.values.toList();
        log("Drivers processed: ${uniqueDrivers.length}");

        // sort and filter the driversWithDistance array based on distance (nearest first)
        uniqueDrivers.sort((a, b) => a['distanceInM'].compareTo(b['distanceInM']));

        if (uniqueDrivers.isEmpty) {
          // Return error response if no available drivers found
          log("No drivers found");

          // cancel trip for onHold drivers
          for (String driverId in onHoldDriverIdList) {
            log("system cancelling $driverId");
            await cancelTrip({
              "driverId": driverId,
              "riderId": reqBody["riderId"],
              "cancelledBy": "SYSTEM",
            });
          }

          yield Response(
            jsonEncode({
              "ok": false,
              "msg": "Drivers are busy try again.",
            }),
            401,
          );
        }

        log("${uniqueDrivers.length} unique drivers found");
        yield Response(
          jsonEncode({
            "ok": true,
            "msg": "${uniqueDrivers.length} drivers found.",
            "data": {
              "drivers": uniqueDrivers,
            }
          }),
          200,
        );
      }
    } catch (error, stackTrace) {
      log("Error in searchRideStream: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      yield Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  // Add this at the beginning of your function to define the timer variable.
  Timer? _cancelTimer;
  StreamController<Response>? _controller;

  @override
  Stream<Response> bookRideStream(Map<String, dynamic> reqBody) async* {
    try {
      _controller = StreamController<Response>();

      // Find the driver document in the drivers collection based on the driverId
      final driverLocationDoc = await _driversLocationCollection.doc(reqBody["driverId"]).get();

      // Check if the driver exits and is a new ride request
      if (!driverLocationDoc.exists && reqBody["newRideRequest"]) {
        yield Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver offline. Please try again",
          }),
          500,
        );
      }

      // Check if the status is trip ended and is a new ride request
      final driverData = driverLocationDoc.data() as Map;
      if (driverData["status"] != "ACTIVE" && reqBody["newRideRequest"]) {
        yield Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver is busy. Please search again",
          }),
          500,
        );
      }

      // Generate the trip id if is a new ride request
      final tripId = reqBody["newRideRequest"] ? genTransactionID() : reqBody["onGoingTripId"];

      // getting trip time out from trip settings
      final Map<String, dynamic> tripSettings = await getTripSettings();
      int tripTimeoutSeconds = 15, tripTimeoutMinute = 3;
      if (tripSettings.isNotEmpty) {
        tripTimeoutSeconds = tripSettings["tripTimeoutSeconds"] ?? 15;
        tripTimeoutMinute = tripSettings["tripTimeoutMinute"] ?? 3;
      }

      if (reqBody["newRideRequest"]) {
        // Parse user and destination geopoints from the request
        final List<double> pickupGeopoint = List<double>.from(reqBody['riderPosition']['geopoint']);
        final List<double> destinationGeopoint = List<double>.from(reqBody['destinationPosition']['geopoint']);

        // Create GeoPoint objects for user and destination positions
        final pickupPosition = GeoPoint(pickupGeopoint[0], pickupGeopoint[1]);
        final destinationPosition = GeoPoint(destinationGeopoint[0], destinationGeopoint[1]);

        final GeoFirePoint pickupLocation = GeoFirePoint(GeoPoint(pickupGeopoint[0], pickupGeopoint[1]));
        final double destinationDistanceInKm = pickupLocation.distanceBetweenInKm(
          geopoint: GeoPoint(destinationGeopoint[0], destinationGeopoint[1]),
        );
        final double destinationDistanceInM = destinationDistanceInKm * 1000;

        List<LatLng> locations = [
          LatLng(pickupGeopoint[0], pickupGeopoint[1]),
          LatLng(destinationGeopoint[0], destinationGeopoint[1]),
        ];

        final destinationDuration = await getDurationInSeconds(locations);

        // Update driver location status and current ride details
        await _driversLocationCollection.doc(reqBody["driverId"]).update({
          "status": "CALLED",
          "currentRideDetails": {
            "destinationInText": reqBody["destinationInText"],
            "destinationDistanceInKm": destinationDistanceInKm,
            "destinationDistanceInM": destinationDistanceInM,
            "destinationDuration": destinationDuration,
            "riderLocationInText": reqBody["riderLocationInText"],
            "riderNearbyLocation": reqBody["riderNearbyLocation"],
            "destinationPosition": destinationPosition,
            "destinationGeofenceId": reqBody["destinationGeofenceId"],
            "riderPosition": pickupPosition,
            "riderId": reqBody["riderId"],
            "riderPhone": reqBody["riderPhone"],
            "riderName": reqBody["riderName"],
            "riderPicture": reqBody["riderPicture"],
            "riderFirebaseKey": reqBody["riderFirebaseKey"],
            "paymentMethod": reqBody["paymentMethod"] ?? "CASH",
            "promoCode": reqBody["promoCode"],
            "discountPercentage": reqBody["discountPercentage"],
            "stops": [
              for (var stop in reqBody["stops"])
                {
                  "geopoint": GeoPoint(stop["geopoint"][0], stop["geopoint"][1]),
                  "address": stop["address"],
                  "name": stop["name"],
                  "geofenceId": stop["geofenceId"],
                },
            ],
            "serviceType": reqBody["serviceType"],
          },
          'currentTripDetails': {
            'tripId': tripId,
            "estimatedTotalAmount": reqBody["estimatedTotalAmount"],
            "vehicleTypeBaseFare": reqBody["vehicleTypeBaseFare"],
          },
        });

        // Update driver with current ride details
        await _driversCollection.doc(reqBody["driverId"]).set({
          "status": "CALLED",
          "currentRideDetails": {
            "destinationInText": reqBody["destinationInText"],
            "riderLocationInText": reqBody["riderLocationInText"],
            "riderNearbyLocation": reqBody["riderNearbyLocation"],
            "destinationPosition": destinationPosition,
            "destinationGeofenceId": reqBody["destinationGeofenceId"],
            "riderPosition": pickupPosition,
            "riderId": reqBody["riderId"],
            "driverId": reqBody["driverId"],
            "riderPhone": reqBody["riderPhone"],
            "riderName": reqBody["riderName"],
            "riderPicture": reqBody["riderPicture"],
            "riderFirebaseKey": reqBody["riderFirebaseKey"],
            "paymentMethod": reqBody["paymentMethod"] ?? "CASH",
            "promoCode": reqBody["promoCode"],
            "discountPercentage": reqBody["discountPercentage"],
            "stops": [
              for (var stop in reqBody["stops"])
                {
                  "geopoint": GeoPoint(stop["geopoint"][0], stop["geopoint"][1]),
                  "address": stop["address"],
                  "name": stop["name"],
                  "geofenceId": stop["geofenceId"],
                },
            ],
            "serviceType": reqBody["serviceType"],
          },
          'currentTripDetails': {
            'tripId': tripId,
            "estimatedTotalAmount": reqBody["estimatedTotalAmount"],
            "vehicleTypeBaseFare": reqBody["vehicleTypeBaseFare"],
          },
          "requestTimeoutSec": tripTimeoutSeconds,
        });

        // create a new document with the trip data
        await _tripsCollection.doc(tripId).set({
          "createAt": DateTime.now(),
          "tripId": tripId,
          "status": "PENDING",
          "riderId": reqBody["riderId"],
          "pickupLocation": reqBody["riderLocationInText"],
          "pickupLat": pickupGeopoint[0],
          "pickupLog": pickupGeopoint[1],
          "pickupNearbyLocation": reqBody["riderNearbyLocation"],
          'destinationLocation': reqBody['destinationInText'],
          'destinationLat': destinationGeopoint[0],
          'destinationLog': destinationGeopoint[1],
          "destinationDistanceInKm": destinationDistanceInKm,
          "destinationDistanceInM": destinationDistanceInM,
          "destinationDuration": destinationDuration,
          "destinationGeofenceId": reqBody["destinationGeofenceId"],
          'vehicleType': driverData["data"]['vehicleType'],
          'vehicleMake': driverData["data"]['vehicleMake'],
          'vehicleModel': driverData["data"]['vehicleModel'],
          'vehicleYear': driverData["data"]['vehicleYear'],
          'vehicleNumber': driverData["data"]['vehicleNumber'],
          'vehicleColor': driverData["data"]['vehicleColor'],
          'paymentMethod': reqBody['paymentMethod'] ?? 'CASH',
          'promoCode': reqBody['promoCode'],
          'discountPercentage': reqBody['discountPercentage'],
          "riderFirebaseKey": reqBody["riderFirebaseKey"],
          'tries': 0,
          "driverId": reqBody["driverId"],
          "driverPhoto": reqBody["driverPhoto"],
          "driverName": reqBody["driverName"],
          "driverPhone": reqBody["driverPhone"],
          "estimatedTotalAmount": reqBody["estimatedTotalAmount"],
          "vehicleTypeBaseFare": reqBody["vehicleTypeBaseFare"],
          "stops": [
            for (var stop in reqBody["stops"])
              {
                "geopoint": GeoPoint(stop["geopoint"][0], stop["geopoint"][1]),
                "address": stop["address"],
                "name": stop["name"],
                "geofenceId": stop["geofenceId"],
              },
          ],
          "serviceType": reqBody["serviceType"],
          "contactedDrivers": [reqBody["driverId"]],
          "requestTimeoutSec": tripTimeoutSeconds,
        });

        // saving trip id to user collection
        await _userCollection.doc(reqBody["riderId"]).update({"currentTripId": tripId});

        if (driverData["data"]['driverFirebaseKey'] != null) {
          sendNotification(
            '🚖 Pickme',
            "You're booked for a ride! Time to be a hero on wheels for your passenger!",
            driverData["data"]['driverFirebaseKey'],
            {
              "tripId": tripId,
              "page": "bookings",
              "driverId": reqBody["driverId"],
            },
          );
        } else {
          log("No driver firebase key found");
        }
      }

      // Set up the timer before starting the driver status stream
      _cancelTimer = Timer(Duration(minutes: tripTimeoutMinute), () async {
        try {
          // Add the timeout response to the stream
          if (!_controller!.isClosed) {
            _controller!.add(Response(
              jsonEncode({
                'ok': false,
                'msg': 'No driver responded within $tripTimeoutMinute minutes. Trip canceled.',
              }),
              408, // Using 408 Request Timeout status code
            ));
            await _controller!.close();
          }
        } catch (e) {
          log("Error in timer callback: $e");
        }
      });

      // Merge the timer's response with the driver status stream
      yield* Stream.multi((MultiStreamController<Response> controller) {
        // Add the controller to receive timer responses
        if (!_controller!.isClosed) {
          _controller!.stream.listen(
            (response) => controller.add(response),
            onError: (error) => controller.addError(error),
            onDone: () => controller.close(),
          );
        }

        // Listen to driver status changes
        _driversCollection.doc(reqBody["driverId"]).snapshots().listen(
          (driver) async {
            final driverData = driver.data() as Map;

            switch (driverData["status"]) {
              case "ACCEPTED":
                _cancelTimer?.cancel();
                controller.add(Response(
                  jsonEncode({
                    'msg': 'Ride accepted.',
                    'data': {
                      'tripId': tripId,
                      "status": "RIDE-ACCEPTED",
                      "actionDate": driverData["actionDate"],
                    },
                  }),
                  200,
                ));
                break;

              case "ARRIVED-PICKUP":
                _cancelTimer?.cancel();
                controller.add(Response(
                  jsonEncode({
                    'msg': 'Driver has arrived',
                    'data': {
                      'tripId': tripId,
                      "status": "ARRIVED-PICKUP",
                    },
                  }),
                  200,
                ));
                break;

              case "TRIP-STARTED":
                _cancelTimer?.cancel();
                controller.add(Response(
                  jsonEncode({
                    'msg': 'Trip started',
                    'data': {
                      'tripId': tripId,
                      "status": "TRIP-STARTED",
                    },
                  }),
                  200,
                ));
                break;

              case "TRIP-ENDED":
                _cancelTimer?.cancel();
                controller.add(Response(
                  jsonEncode({
                    'msg': 'Trip ended',
                    'data': {
                      'tripId': tripId,
                      "status": "TRIP-ENDED",
                    },
                  }),
                  200,
                ));
                controller.close();
                break;

              case "RIDER-CANCEL":
                _cancelTimer?.cancel();
                controller.close();
                break;

              case "ONHOLD":
                controller.add(Response(
                  jsonEncode({
                    'ok': false,
                    'msg': 'Searching new driver',
                    "driverId": driver.id,
                  }),
                  300,
                ));
                await _driversLocationCollection.doc(driver.id).update({
                  'status': 'ACTIVE',
                });
                controller.close();
                break;

              default:
                if (driverData["status"] != "CALLED") {
                  await _driversLocationCollection.doc(driver.id).update({
                    'status': 'ACTIVE',
                  });

                  // if (driverData['driverFirebaseKey'] != null) {
                  //   sendNotification('', "Ready for rides? Go online.", driverData['driverFirebaseKey'], null);
                  // }

                  controller.add(Response(
                    jsonEncode({
                      'ok': false,
                      'msg': 'Driver is busy, please try again later.',
                    }),
                    401,
                  ));
                  controller.close();
                }
            }
          },
          onError: (error) {
            controller.addError(error);
            controller.close();
          },
          onDone: () {
            controller.close();
          },
        );
      });
    } catch (error, stackTrace) {
      log("Error in bookRide: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      yield Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    } finally {
      // Cleanup
      // _cancelTimer?.cancel();
      log("close 7");
      await _controller?.close();
    }
  }

  @override
  Future<Response> cancelTrip(Map<String, dynamic> reqBody) async {
    try {
      final String? driverId = reqBody['driverId'];
      final String? cancelledBy = reqBody['cancelledBy'];

      // Find the driver document in the drivers collection based on the driverId
      final DocumentSnapshot driverLocationSnapshot = await _driversLocationCollection.doc(driverId).get();

      // Check if the driver exists
      if (!driverLocationSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found.",
          }),
          500,
        );
      }

      final driverLocationData = driverLocationSnapshot.data() as Map;

      // Find the trip document in the trips collection based on the tripId

      final String? tripId = driverLocationData['currentTripDetails']['tripId'];
      final DocumentReference tripDoc = _tripsCollection.doc(tripId);

      // Check if trip exists
      final DocumentSnapshot tripSnapshot = await tripDoc.get();
      if (!tripSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Trip not found.",
          }),
          500,
        );
      }

      // Check trip current status if driver is on his way to pickup location
      // if (cancelledBy != "SYSTEM" && driverLocationData['status'] != 'RIDE-ACCEPTED') {
      //   return Response(
      //     jsonEncode({
      //       "ok": false,
      //       "msg": "Sorry, you cannot cancel the trip at this stage",
      //     }),
      //     401,
      //   );
      // }

      // Update the trip status to "TRIP-CANCELLED"
      await tripDoc.update({
        'status': 'TRIP-CANCELLED',
        'cancelledBy': cancelledBy == 'SYSTEM'
            ? "SYSTEM"
            : cancelledBy == 'DRIVER'
                ? 'DRIVER'
                : 'RIDER',
      });

      // Update the driver's status
      await _driversCollection.doc(driverId).update({
        'status': cancelledBy == 'DRIVER' ? 'ONHOLD' : 'RIDER-CANCEL',
        'go_live_time': cancelledBy == 'DRIVER' ? null : driverLocationData['go_live_time'],
      });

      // removing current trip id from user collection
      await _userCollection.doc(reqBody["riderId"]).update({"currentTripId": ""});
      await _userCollection.doc(reqBody["driverId"]).update({"currentTripId": ""});

      // resetting drivers location for another incoming ride request
      await _driversLocationCollection.doc(driverId).update({
        'status': 'ACTIVE',
        'go_live_time': driverLocationData['go_live_time'],
        "currentTripDetails": {},
        "currentRideDetails": {},
      });

      // Send notifications based on who cancelled the trip
      final String? riderFirebaseKey = driverLocationData['currentRideDetails']['riderFirebaseKey'];
      final String? driverFirebaseKey = driverLocationData['data']['driverFirebaseKey'];

      if (cancelledBy == 'DRIVER' && riderFirebaseKey != null) {
        sendNotification(
          '🔴 Pickme',
          "Oops! Your driver had to cancel. Don't worry, just request a new ride!",
          riderFirebaseKey,
          null,
        );
      } else if (cancelledBy == 'RIDER' && driverFirebaseKey != null) {
        sendNotification(
          '🔴 Pickme',
          "Rider cancelled. Keep your app online and be ready for the next trip.",
          driverFirebaseKey,
          null,
        );
      }

      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Trip Cancelled.",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in cancelTrip: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<void> recordWorkerLiveLocation(Map<String, dynamic> reqBody) async {
    final String driverId = reqBody["userId"];

    // check if a drvier exists in the driver collection
    final DocumentSnapshot driverDoc = await _driversLocationCollection.doc(driverId).get();

    if (driverDoc.exists) {
      final Map<String, dynamic> driverPositionToUpdate = {
        "position": {
          "geohash": reqBody["geohash"],
          "geopoint": GeoPoint(
            reqBody["lat"],
            reqBody["log"],
          ),
          "heading": reqBody["heading"],
        },
      };

      await _driversLocationCollection.doc(driverId).update(driverPositionToUpdate);
    }
  }

  @override
  Stream<DriverRequestModel?> getDriverRequest(String driverId, Position currentLocation) async* {
    // find the driver document for request

    await for (var driverDoc in _driversCollection.doc(driverId).snapshots()) {
      if (!driverDoc.exists) yield null;

      try {
        final driverData = driverDoc.data() as Map;
        log("$driverData");
        DriverRequestModel model = DriverRequestModel.fromJson(driverData);
        await model.driverCompleteRequest(currentLocation);
        yield model;
      } catch (error, stackTrace) {
        reportErrors(
          error.toString(),
          stackTrace.toString(),
          requestBody: {"driverId": driverId},
        );
        yield null;
      }
    }
  }

  @override
  Future<Response> acceptRide(Map<String, dynamic> reqBody) async {
    try {
      // Extract the driverId and status from the request body
      final String? driverId = reqBody['driverId'];
      final String? status = reqBody['status'];
      final String? tripId = reqBody['tripId'];
      final String? riderId = reqBody['riderId'];

      final DocumentSnapshot driverSnapshot = await _driversCollection.doc(driverId).get();
      if (!driverSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found.",
          }),
          500,
        );
      }

      final driverData = driverSnapshot.data() as Map;

      // Check trip current status
      final String currentStatus = driverData["status"];
      if (currentStatus != "CALLED") {
        return Response(
          jsonEncode({
            "ok": false,
            'msg': 'Sorry, you must be called to either accept or reject a ride request.',
          }),
          500,
        );
      }

      // Update the status of the driver to "ACCEPT" or "ONHOLD"
      await _driversCollection.doc(driverId).update({
        'status': status == "ACCEPT" ? "ACCEPTED" : "ONHOLD",
        'actionDate': DateTime.now().toIso8601String(),
      });

      if (status == "ACCEPT") {
        // update trip new document with the trip data
        await _tripsCollection.doc(tripId).update({
          "updateAt": DateTime.now(),
          "status": "ACCEPTED",
          'tries': 1,
          "driverFirebaseKey": reqBody['driverFirebaseKey'],
        });

        // Proceed with updating the driver location status and current trip details
        await _driversLocationCollection.doc(driverId).update({
          'status': 'RIDE-ACCEPTED', // Set the driver status to "RIDE-ACCEPTED"
        });

        // updating current trip id from user collection
        await _userCollection.doc(reqBody["driverId"]).update({"currentTripId": reqBody["tripId"]});

        if (reqBody['riderFirebaseKey'] != null) {
          sendNotification(
            '🚖 Pickme',
            'Your Pickme ride is on the way!. Get ready to go!',
            reqBody['riderFirebaseKey'],
            {
              "tripId": tripId!,
              "page": "bookings",
              "riderId": riderId ?? "",
            },
          );
        }
      } else {
        await _driversLocationCollection.doc(driverId).update({
          'status': 'ACTIVE',
        });
        await _userCollection.doc(reqBody["driverId"]).update({"currentTripId": ""});
      }
      return Response(
        jsonEncode({
          "ok": true,
          'msg': status == "ACCEPT" ? 'Trip request accepted.' : 'Trip request rejected',
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in acceptRide: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> arriveAtPickup(Map<String, dynamic> reqBody) async {
    try {
      final String? driverId = reqBody['driverId'];
      final String? riderId = reqBody['riderId'];
      bool sendNotificationPermitted = reqBody['sendNotification'] ?? true;

      // Find the driver document in the drivers collection based on the driverId
      final DocumentSnapshot driverSnapshot = await _driversCollection.doc(driverId).get();

      // Check if the driver exists
      if (!driverSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found.",
          }),
          500,
        );
      }

      final driverData = driverSnapshot.data() as Map;
      final String tripId = driverData['currentTripDetails']['tripId'];
      final DocumentReference tripDoc = _tripsCollection.doc(tripId);

      // Check if trip exists
      final DocumentSnapshot tripSnapshot = await tripDoc.get();
      if (!tripSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Trip not found.",
          }),
          500,
        );
      }

      // Check driver current status
      if (driverData["status"] != "ACCEPTED") {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Trip must be accepted by driver to start",
          }),
          500,
        );
      }

      // Update the trip status
      final String timeArrive = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await tripDoc.update({
        "status": "ARRIVED-PICKUP",
        "arrivedAtPickup": timeArrive,
      });

      // Update driver status
      await _driversCollection.doc(driverId).update({
        'status': 'ARRIVED-PICKUP',
        "arrivedAtPickup": timeArrive,
      });
      await _driversLocationCollection.doc(driverId).update({
        'status': 'ARRIVED-PICKUP',
        "arrivedAtPickup": timeArrive,
      });
      final String? riderFirebaseKey = driverData['currentRideDetails']['riderFirebaseKey'];

      if (riderFirebaseKey != null && sendNotificationPermitted) {
        sendNotification(
          '🟢 Pickme',
          "Driver is here",
          riderFirebaseKey,
          {
            "tripId": tripId,
            "page": "bookings",
            "riderId": riderId ?? "",
          },
        );
      }
      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Driver arrived at pickup",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in arriveAtPickup: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> startTrip(Map<String, dynamic> reqBody) async {
    try {
      // Get the current time formatted as 'YYYY-MM-DD HH:mm:ss'
      final String periodStart = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Extract the driverId from the request body
      final String? driverId = reqBody['driverId'];
      final String? riderId = reqBody['riderId'];
      bool sendNotificationPermitted = reqBody['sendNotification'] ?? true;

      // Find the driver document in the drivers collection based on the driverId
      final DocumentSnapshot driverLocationSnapshot = await _driversLocationCollection.doc(driverId).get();

      // Check if the driver exists
      if (!driverLocationSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found.",
          }),
          500,
        );
      }

      final driverLocationData = driverLocationSnapshot.data() as Map;
      final String tripId = driverLocationData['currentTripDetails']['tripId'];
      final DocumentReference tripDoc = _tripsCollection.doc(tripId);

      // Check if trip exists
      final DocumentSnapshot tripSnapshot = await tripDoc.get();
      if (!tripSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Trip not found.",
          }),
          500,
        );
      }

      // Check driver current status
      if (driverLocationData["status"] != "RIDE-ACCEPTED") {
        // return Response(
        //   jsonEncode({
        //     "ok": false,
        //     "msg": "Trip must be accepted by driver to start",
        //   }),
        //   500,
        // );

        // update trip new document with the trip data
        await _tripsCollection.doc(tripId).update({
          "updateAt": DateTime.now(),
          "status": "ACCEPTED",
          "driverId": driverId,
          'tries': 1,
        });

        // Proceed with updating the driver location status and current trip details
        await _driversLocationCollection.doc(driverId).update({
          'status': 'RIDE-ACCEPTED', // Set the driver status to "RIDE-ACCEPTED"
        });

        if (reqBody['riderFirebaseKey'] != null && sendNotificationPermitted) {
          // sendNotification(
          //   '🚖 Pickme',
          //   'Your Pickme ride is on the way!. Get ready to go!',
          //   reqBody['riderFirebaseKey'],
          //   {
          //     "tripId": tripId,
          //     "page": "bookings",
          //     "riderId": riderId ?? "",
          //   },
          // );
        }
      }

      // Update the trip status and periodStart time
      await tripDoc.update({
        'status': 'TRIP-STARTED',
        'periodStart': periodStart,
      });

      // Update driver status
      await _driversCollection.doc(driverId).update({
        'status': 'TRIP-STARTED',
        'currentTripDetails.periodStart': periodStart,
      });

      final String? driverFirebaseKey = driverLocationData['data']['driverFirebaseKey'];
      final String? riderFirebaseKey = driverLocationData['currentRideDetails']['riderFirebaseKey'];

      if (driverFirebaseKey != null && sendNotificationPermitted) {
        // sendNotification(
        //   '🟢 Pickme',
        //   "Trip started. Buckle up!",
        //   driverFirebaseKey,
        //   {
        //     "tripId": tripId,
        //     "page": "bookings",
        //     "driverId": driverId ?? "",
        //   },
        // );
      }

      if (riderFirebaseKey != null && sendNotificationPermitted) {
        // sendNotification(
        //   '🟢 Pickme',
        //   "Buckle up! Trip in progress.",
        //   riderFirebaseKey,
        //   {
        //     "tripId": tripId,
        //     "page": "bookings",
        //     "riderId": riderId ?? "",
        //   },
        // );
      }

      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Trip Started.",
          'data': {
            'driverId': driverId,
            'tripId': tripId,
          }
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in starTrip: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> updateOnGoingTripWithPolylines(String driverId, String points) async {
    try {
      await _driversLocationCollection.doc(driverId).update({'points': points});

      return Response(
        jsonEncode({"ok": true, "msg": "Trip update."}),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in updateOnGoingTripWithPolylines: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: {"driverId": driverId},
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> tripEnded(Map<String, dynamic> reqBody, FeeModel feeModel) async {
    try {
      final DateTime periodEnd = DateTime.now();

      final String driverId = reqBody['driverId'];
      final String riderId = reqBody['riderId'];
      String? tripId = reqBody['tripId'];
      bool sendNotificationPermitted = reqBody['sendNotification'] ?? true;

      // Find the driver document in the drivers collection based on the driverId
      final DocumentSnapshot driverLocationSnapshot = await _driversLocationCollection.doc(driverId).get();

      // Check if the driver exists
      if (!driverLocationSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found.",
          }),
          500,
        );
      }

      final driverLocationData = driverLocationSnapshot.data() as Map;
      tripId = tripId ?? driverLocationData['currentTripDetails']['tripId'];

      final DocumentReference tripDoc = _tripsCollection.doc(tripId);

      // Check if trip exists
      final DocumentSnapshot tripSnapshot = await tripDoc.get();
      if (!tripSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Trip not found.",
          }),
          500,
        );
      }

      // removing current trip id from user collection
      // await _userCollection.doc(reqBody["riderId"]).update({"currentTripId": ""});
      // await _userCollection.doc(reqBody["driverId"]).update({"currentTripId": ""});

      GeoPoint pickupPoint = driverLocationData['currentRideDetails']['riderPosition'];
      final double pickUpLatitude = pickupPoint.latitude;
      final double pickUpLongitude = pickupPoint.longitude;

      // Get the destination position from the request body
      final List<dynamic> position = reqBody['position']['geopoint'];
      final double destinationLatitude = position[0];
      final double destinationLongitude = position[1];

      // Generate the Google Maps API URL for directions
      final String gMapUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$pickUpLatitude,$pickUpLongitude&destination=$destinationLatitude,$destinationLongitude&key=${Properties.googleApiKey}';

      // Send a request to the Google Maps API to get the distance
      final http.Response response = await http.get(Uri.parse(gMapUrl));

      if (response.statusCode != 200) {
        // sendNotification(
        //   '🚩 Admin',
        //   'TRIP-COMPLETED-UNPAID: Trip ID $tripId for Driver ($driverId) could not be completed because trip distance could not be determined',
        //   Properties.adminToken,
        //   {
        //     "tripId": tripId!,
        //     "page": "bookings",
        //   },
        // );
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Trip distance could not be determined. Please try again.",
          }),
          500,
        );
      }

      final Map<String, dynamic> gMapData = json.decode(response.body);
      // final double km = gMapData['routes'].isNotEmpty
      //     ? convertMeterToKilometer(gMapData['routes'][0]['legs'][0]['distance']['text'])
      //     : 0;

      // Calculate the total trip duration in minutes and the fees charged using the trip distance and duration
      final tripData = tripSnapshot.data() as Map;
      final int? totalMinutes = await getTripMinuteFromDate(
        DateTime.parse(tripData['periodStart']),
        periodEnd,
      );
      // final Map<String, dynamic> feeData = await getTripTotalFees(
      //   km,
      //   totalMinutes!,
      //   double.parse(tripData['discountPercentage'].toString()),
      //   double.parse(tripData["vehicleTypeBaseFare"].toString()),
      // );

      // ignore: unnecessary_null_comparison
      if (totalMinutes == null) {
        // sendNotification(
        //   '🚩 Admin',
        //   'Trips minutes could not be determined. Driver ($driverId). Trip ID: $tripId. Start time: ${driverLocationData['currentTripDetails']['periodStart']} .End time: $periodEnd',
        //   Properties.adminToken,
        //   {"tripId": tripId!, "page": "bookings"},
        // );
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Trips minutes could not be determined. Please try again.",
          }),
          500,
        );
      }

      await tripDoc.update({
        'status': 'ENDED',
        'destinationLocation':
            gMapData['routes'].isNotEmpty ? gMapData['routes'][0]['legs'][0]['end_address'] : 'Unknown',
        'destinationLat': gMapData['routes'].isNotEmpty
            ? gMapData['routes'][0]['legs'][0]['end_location']['lat']
            : destinationLatitude,
        'destinationLog': gMapData['routes'].isNotEmpty
            ? gMapData['routes'][0]['legs'][0]['end_location']['lng']
            : destinationLongitude,
        'tripKm': feeModel.data?.totalKm,
        'totalKmCharged': feeModel.data?.totalKmCharged,
        'totalMinutes': feeModel.data?.totalMinutes,
        'totalMinCharged': feeModel.data?.totalMinCharged,
        'driverCommission': "",
        'pickmePercentage': "",
        'pickmeCommission': "",
        'subTotal': feeModel.data?.subTotal,
        'grandTotal': feeModel.data?.grandTotal,
        'discountPercentage': feeModel.data?.discountPercentage,
        'discountAmount': feeModel.data?.discountAmount,
        'paymentMethod': driverLocationData['currentRideDetails']['paymentMethod'],
        'promoCode': driverLocationData['currentRideDetails']['promoCode'],
        'periodEnd': reqBody['periodEnd'],
      });

      // Update the status of the driver to "TRIP-ENDED"
      await _driversCollection.doc(driverId).update({
        'currentRideDetails.totalFee': feeModel.data?.grandTotal,
        'currentTripDetails.periodEnd': reqBody['periodEnd'],
        'status': 'TRIP-ENDED',
        'go_live_time': '',
      });

      await _driversLocationCollection.doc(driverId).update({
        'status': 'ACTIVE',
      });

      if (driverLocationData['currentRideDetails']['riderFirebaseKey'] != null && sendNotificationPermitted) {
        sendNotification(
          '⚪ Pickme',
          'Your trip fare is GH¢ ${feeModel.data?.grandTotal}. Thank you for riding with us! If you have any questions or need assistance, please don\'t hesitate to reach out to our support team. Safe travels!',
          driverLocationData['currentRideDetails']['riderFirebaseKey'],
          {
            "tripId": tripId!,
            "page": "bookings",
            "driverId": driverId,
            "riderId": riderId,
          },
        );
      }

      if (driverLocationData['data']['driverFirebaseKey'] != null && sendNotificationPermitted) {
        // sendNotification(
        //   '⚪ Pickme',
        //   'Trip fare is GH¢ ${feeModel.data?.grandTotal}. Thank you for providing a great service! If you encounter any issues or have questions, feel free to contact our support team. Keep up the excellent work!',
        //   driverLocationData['data']['driverFirebaseKey'],
        //   {
        //     "tripId": tripId!,
        //     "page": "bookings",
        //     "driverId": driverId,
        //   },
        // );
      }

      return Response(
        jsonEncode({
          "ok": true,
          'msg': 'Trip Fee Data',
          'data': {
            "tripId": tripId,
            'paymentMethod': driverLocationData['currentRideDetails']['paymentMethod'],
            "riderName": driverLocationData['currentRideDetails']["riderName"],
            "riderPicture": driverLocationData['currentRideDetails']["riderPicture"],
          }
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in trpEnded: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> tripCompleted(Map<String, dynamic> reqBody) async {
    try {
      final String? driverId = reqBody['driverId'];

      // Find the driver document in the drivers collection based on the driverId
      final DocumentSnapshot driverLocationSnapshot = await _driversLocationCollection.doc(driverId).get();

      // Check if the driver exists
      if (!driverLocationSnapshot.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found.",
          }),
          500,
        );
      }

      final driverLocationData = driverLocationSnapshot.data() as Map;
      // final String tripId = driverLocationData['currentTripDetails']['tripId'];

      final String? riderFirebaseKey = driverLocationData['currentRideDetails']['riderFirebaseKey'];

      // Update the driver's status and position
      await _driversLocationCollection.doc(driverId).update({
        'status': 'ACTIVE',
        'currentRideDetails': {},
        'currentTripDetails': {},
        'go_live_time': DateTime.now(),
        'position': {
          'geohash': reqBody['position']['geohash'] ?? '',
          'geopoint': GeoPoint(
            (reqBody['position']['geopoint'][0] as num).toDouble(),
            (reqBody['position']['geopoint'][1] as num).toDouble(),
          ),
          "heading": reqBody['position']["heading"],
        },
      });

      await _driversCollection.doc(driverId).update({
        'status': 'ACTIVE',
        'currentRideDetails': {},
        'currentTripDetails': {},
        'go_live_time': DateTime.now(),
      });

      await _userCollection.doc(reqBody["driverId"]).update({"currentTripId": ""});

      if (driverLocationData['data']['driverFirebaseKey'] != null) {
        // sendNotification(
        //   '⚪ Pickme',
        //   'Trip completed successfully. Time to head back for your next journey.',
        //   driverLocationData['data']['driverFirebaseKey'],
        //   {"page": "bookings"},
        // );
      }

      if (riderFirebaseKey != null) {
        // sendNotification(
        //   '⚪ Pickme',
        //   'Hope you had a pleasant ride. See you on your next adventure!',
        //   riderFirebaseKey,
        //   {"page": "bookings"},
        // );
      }

      return Response(
        jsonEncode({
          "ok": true,
          'msg': 'Trip Completed.',
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in trpEnded: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<TripDetailsModel?> tripDetails(String tripId) async {
    DocumentSnapshot tripDoc = await _tripsCollection.doc(tripId).get();

    if (!tripDoc.exists) return null;

    final tripData = tripDoc.data() as Map;
    log("$tripData");
    TripDetailsModel model = TripDetailsModel.fromJson(tripData);
    return model;
  }

  @override
  Stream<TripDetailsModel?> userTripDetailsStream(String userId) async* {
    String? lastTripId;
    TripDetailsModel? lastTripDetails;

    await for (var userDoc in _userCollection.doc(userId).snapshots()) {
      if (!userDoc.exists) {
        yield null; // User document doesn't exist
        continue; // Skip to the next iteration
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      log("User Data: $userData");

      if (userData.containsKey("currentTripId")) {
        String tripId = userData["currentTripId"];

        // If there's a tripId and it has changed since the last update
        if (tripId.isNotEmpty && tripId != lastTripId) {
          lastTripId = tripId;

          // Listen to the specific trip document changes
          await for (var tripDoc in _tripsCollection.doc(tripId).snapshots()) {
            if (!tripDoc.exists) {
              yield null; // Trip document doesn't exist
              continue; // Skip to the next iteration
            }

            final tripData = tripDoc.data() as Map<String, dynamic>;
            TripDetailsModel model = TripDetailsModel.fromJson(tripData);

            // Yield only if trip details have changed
            if (model != lastTripDetails) {
              lastTripDetails = model;
              yield model;
            }
          }
        }
      }
    }
  }

  @override
  Future<TripDetailsModel?> userOnGoingTrip(String userId) async {
    DocumentSnapshot userDoc = await _userCollection.doc(userId).get();

    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map;
    if (!userData.containsKey("currentTripId")) {
      debugPrint("no current trip id");
      return null;
    }

    String tripId = userData["currentTripId"];
    if (tripId == "") return null;

    TripDetailsModel? model = await tripDetails(tripId);
    return model;
  }

  @override
  Future<Response> saveWorkerServices(Map<String, dynamic> reqBody, {isNewUser = false}) async {
    bool connection = await checkConnection();
    if (!connection) {
      return Response(
        jsonEncode({
          "ok": false,
          "msg": "No internet connection",
        }),
        500,
      );
    }
    try {
      final String userId = reqBody["userId"];

      // check if a drvier exists in the driver collection and is not a new user
      if (isNewUser) {
        List<String>? servicesList = await getWorkerServices(userId);
        if (servicesList != null) {
          log("Old user");
          return Response(
            jsonEncode({
              "ok": false,
              "msg": "Old user",
            }),
            500,
          );
        }
      } else {
        final DocumentSnapshot driverDoc = await _driversLocationCollection.doc(userId).get();

        if (driverDoc.exists) {
          final driverData = driverDoc.data() as Map;
          final String status = driverData["status"];

          if (status != "INACTIVE") {
            return Response(
              jsonEncode({
                "ok": false,
                "msg": "Saving failed. You must be inactive first",
              }),
              500,
            );
          }
        }
      }

      await _userCollection.doc(userId).update({"services": reqBody["services"]});
      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Saving successful",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in goOnline: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured while going live",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<List<String>?> getWorkerServices(String userId) async {
    DocumentSnapshot userDoc = await _userCollection.doc(userId).get();

    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map;
    if (!userData.containsKey("services")) {
      debugPrint("no worker services found");
      return null;
    }

    return List<String>.from(userData["services"]);
  }

  @override
  Future<List<Map>?> getEmergency(String userId) async {
    DocumentSnapshot userDoc = await _userCollection.doc(userId).get();

    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map;
    if (!userData.containsKey("emergency")) {
      debugPrint("no emergency");
      return null;
    }

    return List<Map>.from(userData["emergency"]);
  }

  @override
  Future<void> reportErrors(
    String error,
    String stackTrace, {
    Map<String, dynamic>? requestBody,
    String? url,
  }) async {
    Set<String> notIncludedList = {
      "firebase_auth/email-already-in-use",
      "Bad state: Cannot add event after closing",
    };

    bool isNotIncluded = notIncludedList.every((data) => !error.contains(data));

    if (isNotIncluded) {
      final now = DateTime.now();
      await _errorLogsCollection.doc(now.millisecondsSinceEpoch.toString()).set({
        "date": now.toIso8601String(),
        "error": error,
        "stackTrace": stackTrace,
        "userId": userModel?.data?.user?.userid ?? "",
        "requestBody": requestBody,
        "url": url,
      });
    }
  }

  @override
  Future<Response> saveEmergency(Map<String, dynamic> reqBody) async {
    bool connection = await checkConnection();
    if (!connection) {
      return Response(
        jsonEncode({
          "ok": false,
          "msg": "No internet connection",
        }),
        500,
      );
    }
    try {
      final String userId = reqBody["userId"];
      final DocumentSnapshot userDoc = await _userCollection.doc(userId).get();
      if (!userDoc.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "User not found",
          }),
          500,
        );
      }

      await _userCollection.doc(userId).update({
        "emergency": reqBody["emergency"],
      });

      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Save succesfully",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in saveEmergency: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured while saving",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> saveWorkerRadius(Map<String, dynamic> reqBody) async {
    bool connection = await checkConnection();
    if (!connection) {
      return Response(
        jsonEncode({
          "ok": false,
          "msg": "No internet connection",
        }),
        500,
      );
    }
    try {
      final String driverId = reqBody["driverId"];

      //find the driver document in the driver collection
      final DocumentSnapshot driverDoc = await _driversLocationCollection.doc(driverId).get();

      if (!driverDoc.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "Driver not found, please make sure you online",
          }),
          500,
        );
      }

      await _driversLocationCollection.doc(driverId).update({
        "radius": reqBody["radius"],
      });

      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Save successfully",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in saveWorkerRadius: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured while saving",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Future<Response> saveUserToken(Map<String, dynamic> reqBody) async {
    try {
      final String userId = reqBody["userId"];
      final DocumentSnapshot userDoc = await _userCollection.doc(userId).get();
      if (!userDoc.exists) {
        return Response(
          jsonEncode({
            "ok": false,
            "msg": "User not found",
          }),
          500,
        );
      }

      await _userCollection.doc(userId).update({
        "token": reqBody["token"],
      });

      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Token Save succesfully",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in saveUserToken: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: reqBody,
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured while saving",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }

  @override
  Stream<String?> userTokenStream(String userId) async* {
    await for (var userDoc in _userCollection.doc(userId).snapshots()) {
      if (!userDoc.exists) {
        yield null; // User document doesn't exist
        continue; // Skip to the next iteration
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      log("User Data: $userData");

      if (userData.containsKey("token")) {
        String userToken = userData["token"];
        yield userToken;
      } else {
        yield null;
      }
    }
  }

  @override
  Future<NotificationsModel?> getNotifications(String userId) async {
    QuerySnapshot<Map<String, dynamic>> notificationDoc =
        await _userCollection.doc(userId).collection("notification").get();

    if (notificationDoc.docs.isEmpty) return null;

    // Combine all notification documents into a single map
    Map<String, dynamic> allNotifications = {};
    for (var doc in notificationDoc.docs) {
      allNotifications[doc.id] = doc.data();
    }

    // log("Fetched Notifications: $allNotifications");

    return NotificationsModel.fromJson(allNotifications);
  }

  @override
  Future<Response> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _userCollection.doc(userId).collection("notification").doc(notificationId).update({
        "read": true,
      });

      return Response(
        jsonEncode({
          "ok": true,
          "msg": "Notification marked as read",
        }),
        200,
      );
    } catch (error, stackTrace) {
      log("Error in markNotificationAsRead: $error\n$stackTrace");
      reportErrors(
        error.toString(),
        stackTrace.toString(),
        requestBody: {"userId": userId, "notificationId": notificationId},
      );

      return Response(
        jsonEncode({
          "ok": false,
          "msg": "An error occured while marking notification as read",
          "error": {
            "msg": error.toString(),
            "stack": stackTrace.toString(),
          }
        }),
        500,
      );
    }
  }
}
