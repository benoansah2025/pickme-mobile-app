import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' hide TravelMode;
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/geofenceCordinateModel.dart';
import 'package:pickme_mobile/models/placeDetailsModel.dart';
import 'package:pickme_mobile/models/placePredictionModel.dart';
import 'package:pickme_mobile/models/tripEstimateModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';

double calculateBearing(LatLng start, LatLng end) {
  double startLat = start.latitude * pi / 180;
  double startLng = start.longitude * pi / 180;
  double endLat = end.latitude * pi / 180;
  double endLng = end.longitude * pi / 180;

  double dLng = endLng - startLng;
  double y = sin(dLng) * cos(endLat);
  double x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

  double bearing = atan2(y, x);
  bearing = bearing * 180 / pi;
  bearing = (bearing + 360) % 360;
  return bearing;
}

/// Calculates the radius of a geofence from a list of coordinates
/// Returns the distance in meters from the center to the furthest point
double calculateRadiusFromCoordinates(List<LatLng> coordinates) {
  if (coordinates.isEmpty) return 0.0;
  if (coordinates.length == 1) return 0.0;

  // Calculate the center point
  LatLng center = calculateCenter(coordinates);
  double maxDistance = 0.0;

  // Find the maximum distance from center to any point
  for (LatLng point in coordinates) {
    double distance = calculateDistance(center, point);
    maxDistance = distance > maxDistance ? distance : maxDistance;
  }

  // Add a small buffer (5%) to ensure coverage
  return maxDistance * 1.05;
}

/// Calculates the center point of a polygon using the arithmetic mean
/// Returns the center point as LatLng
LatLng calculateCenter(List<LatLng> coordinates) {
  if (coordinates.isEmpty) {
    throw ArgumentError('Coordinates list cannot be empty');
  }

  double sumLat = 0.0;
  double sumLng = 0.0;
  int count = 0;

  for (LatLng point in coordinates) {
    if (point.latitude.isFinite && point.longitude.isFinite) {
      sumLat += point.latitude;
      sumLng += point.longitude;
      count++;
    }
  }

  if (count == 0) {
    throw ArgumentError('No valid coordinates found');
  }

  return LatLng(sumLat / count, sumLng / count);
}

/// Calculates the distance between two points using the Haversine formula
/// Returns the distance in meters
double calculateDistance(LatLng point1, LatLng point2) {
  const double earthRadius = 6371000; // Earth's radius in meters

  double toRadians(double degree) => degree * pi / 180.0;

  final double lat1 = toRadians(point1.latitude);
  final double lon1 = toRadians(point1.longitude);
  final double lat2 = toRadians(point2.latitude);
  final double lon2 = toRadians(point2.longitude);

  final double dLat = lat2 - lat1;
  final double dLon = lon2 - lon1;

  final double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * asin(sqrt(a));

  return earthRadius * c;
}

Future<Set<Polyline>?> fetchRouteAndSetPolyline({
  required List<LatLng> locations,
  required String polylineKey,
  required Color color,
}) async {
  DirectionsService.init(Properties.googleApiKey);
  final directionsService = DirectionsService();

  List<DirectionsWaypoint> waypoints = [
    for (LatLng lL in locations.skip(1).take(locations.length - 2))
      DirectionsWaypoint(
        location: '${lL.latitude},${lL.longitude}',
      )
  ];

  final request = DirectionsRequest(
    origin: '${locations.first.latitude},${locations.first.longitude}',
    destination: '${locations.last.latitude},${locations.last.longitude}',
    travelMode: TravelMode.driving,
    waypoints: waypoints,
  );
  Set<Polyline> polylines = {};

  await directionsService.route(request, (
    DirectionsResult response,
    DirectionsStatus? status,
  ) async {
    if (status == DirectionsStatus.ok) {
      // Fetch the encoded polyline from the response
      final route = response.routes?.first;
      final overviewPolyline = route?.overviewPolyline;

      if (overviewPolyline != null) {
         final decodedPath = PolylinePoints.decodePolyline(overviewPolyline.points!);

        polylines.add(
          Polyline(
            polylineId: PolylineId(polylineKey),
            visible: true,
            points: decodedPath.map((e) => LatLng(e.latitude, e.longitude)).toList(),
            color: BColors.primaryColor,
            width: 5,
          ),
        );
      }
    }
  });

  return polylines;
}

Future<List<PlacePredictionModel>> getPlacePredictions(
  String rawInput,
  LatLng currentLocation, {
  required List<List<GeofenceCordinateModel>> allGeofences,
  required String geoAreaName,
}) async {
  String apiKey = Properties.googleApiKey;
  // String country = 'GH';

  String input = "$geoAreaName $rawInput";

  // Open the Hive box
  var box = await Hive.openBox('placePredictions');

  // Define the cache expiration duration (e.g., 1 day)
  const cacheExpirationDuration = Duration(days: 1);
  DateTime now = DateTime.now();

  // Clear outdated cache entries
  for (var key in box.keys) {
    if (box.containsKey('$key-timestamp')) {
      DateTime timestamp = DateTime.parse(box.get('$key-timestamp'));
      if (now.difference(timestamp) > cacheExpirationDuration) {
        box.delete(key);
        box.delete('$key-timestamp'); // Remove the associated timestamp
      }
    }
  }

  // // Check if the input is already cached
  // List<PlacePredictionModel> cachedPredictions = [];
  // for (var key in box.keys) {
  //   if (key.toString().startsWith(input)) {
  //     List<dynamic> cachedData = box.get(key);
  //     cachedPredictions.addAll(
  //       cachedData.map(
  //         (data) => PlacePredictionModel.fromJson(
  //           Map<String, dynamic>.from(data),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // if (cachedPredictions.isNotEmpty) {
  //   return cachedPredictions;
  // }

  List<PlacePredictionModel> placePredictions = [];

  try {
    final response = await http.get(
      // Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json'
      //     '?input=$input'
      //     '&key=$apiKey'
      //     '&components=country:$country'
      //     '&origin=${currentLocation.latitude},${currentLocation.longitude}'
      //     '&keyword=$rawInput'
      //     // '&radius=50000' // Limit initial search radius
      //     ),

      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${currentLocation.latitude},${currentLocation.longitude}'
        '&radius=5000' // Limit initial search radius
        '&keyword=$input'
        '&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final results = _PlacePredictionCompleteResponse.fromJson(response.body).results;

      await Future.wait(
        results.map(
          (PlacePredictionModel prediction) async {
            try {
              LatLng placeLocation = LatLng(prediction.geometry!.location!.lat!, prediction.geometry!.location!.lng!);

              if (allGeofences.isNotEmpty) {
                for (var geofence in allGeofences) {
                  // First, quick check using circular radius
                  double distanceToCenter = calculateDistance(
                    placeLocation,
                    geofence.first.center,
                  );

                  Map<String, dynamic> estimateMap = {};

                  if (distanceToCenter <= geofence.first.radius) {
                    // If within radius, do precise polygon check
                    List<LatLng> polygonPoints = [];

                    for (var coord in geofence) {
                      polygonPoints.add(LatLng(coord.latitude, coord.longitude));
                      estimateMap = {
                        "baseFee": coord.baseFee,
                        "driverPercentage": coord.driverPercentage,
                        "pricePerKm": coord.pricePerKm,
                        "pricePerMinute": coord.pricePerMinute,
                        "services": coord.services,
                        "vehicles": coord.vehicles,
                        "estimateId": coord.estimateId,
                      };
                    }

                    // calculate distance
                    double distance = Geolocator.distanceBetween(
                      currentLocation.latitude,
                      currentLocation.longitude,
                      prediction.geometry!.location!.lat!,
                      prediction.geometry!.location!.lng!,
                    );

                    if (isPointInPolygon(placeLocation, polygonPoints)) {
                      Map<String, dynamic> predictionEstimate = {
                        ...prediction.toJson(),
                        ...estimateMap,
                        ...{"distance": distance},
                      };

                      placePredictions.add(PlacePredictionModel.fromJson(predictionEstimate));
                      return;
                    }
                  }
                }
              } else {
                placePredictions.add(prediction);
              }
            } catch (e, stackTrace) {
              if (kDebugMode) {
                print('Error processing prediction: ${e.toString()} $stackTrace');
              }
            }
          },
        ),
      );

      placePredictions.sort((a, b) => a.distance!.compareTo(b.distance!));

      // Cache the results
      List<Map<String, dynamic>> jsonData = placePredictions
          .map(
            (PlacePredictionModel prediction) => prediction.toJson(),
          )
          .toList();
      await box.put(input, jsonData);
      await box.put('$input-timestamp', now.toIso8601String());
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching predictions: ${e.toString()}');
    }
  }

  return placePredictions;
}

// Check if a point is inside a polygon using ray casting algorithm
bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  bool inside = false;
  int j = polygon.length - 1;

  for (int i = 0; i < polygon.length; i++) {
    if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
        (point.longitude <
            (polygon[j].longitude - polygon[i].longitude) *
                    (point.latitude - polygon[i].latitude) /
                    (polygon[j].latitude - polygon[i].latitude) +
                polygon[i].longitude)) {
      inside = !inside;
    }
    j = i;
  }

  return inside;
}

class _PlacePredictionCompleteResponse {
  final List<PlacePredictionModel> results;

  _PlacePredictionCompleteResponse({required this.results});

  factory _PlacePredictionCompleteResponse.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    final List<dynamic> predictionsJson = data['results'];
    final predictions = predictionsJson.map((json) => PlacePredictionModel.fromJson(json)).toList();
    return _PlacePredictionCompleteResponse(results: predictions);
  }
}

Future<PlaceDetailsModel> getPlaceDetails(String placeId, LatLng currentLocation) async {
  String apiKey = Properties.googleApiKey;
  Map<dynamic, dynamic> cachePlaceMap = {};
  cachePlaceMap = await getHive("placeDetails") ?? {};

  if (cachePlaceMap.containsKey(placeId)) {
    Map<String, dynamic> decodedData = Map<String, dynamic>.from(cachePlaceMap[placeId]);
    final placeDetails = PlaceDetailsModel.fromJson(decodedData);
    return placeDetails;
  } else {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      // caching data
      Map<String, dynamic> decodedData = jsonDecode(response.body);
      PlaceDetailsModel placeDetails = PlaceDetailsModel.fromJson(decodedData);

      // get near by place and select the first one
      PlacePredictionModel? nearbyPlace = await getNearbyPlace(
        currentLocation: currentLocation,
        placeName: placeDetails.name!,
      );

      if (nearbyPlace != null) {
        Map<String, dynamic> placeWithNearBy = {
          ...placeDetails.toJson(),
          ...{"nearbyPlaceName": nearbyPlace.name ?? nearbyPlace.plusCode!.compoundCode},
        };

        logStatement("placeWithNearBy $placeWithNearBy");

        placeDetails = PlaceDetailsModel.fromJson(placeWithNearBy);
        cachePlaceMap[placeId] = placeWithNearBy;
        if (!isCodePlaceName(placeDetails.name!)) {
          await saveHive(key: "placeDetails", data: cachePlaceMap);
        }
      }

      return placeDetails;
    } else {
      throw Exception('Failed to load place details');
    }
  }
}

// check if place name is code
bool isCodePlaceName(String name) {
  // Google Plus Codes are usually in the format like "HQXX+F8P" or "7FG8+V9, City"
  final regex = RegExp(r'^[A-Z0-9]{4,}(\+)?[A-Z0-9]{2,}(,\s?.+)?$');
  return regex.hasMatch(name);
}

Future<PlacePredictionModel?> getNearbyPlace({
  required LatLng currentLocation,
  required String placeName,
}) async {
  String apiKey = Properties.googleApiKey;

  final response = await http.get(
    Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${currentLocation.latitude},${currentLocation.longitude}'
      '&radius=100' // Limit initial search radius 50meters
      '&key=$apiKey',
    ),
  );

  if (response.statusCode == 200) {
    final results = _PlacePredictionCompleteResponse.fromJson(response.body).results;

    List<PlacePredictionModel?> sortedResultsList = [];

    await Future.wait(
      results.map(
        (PlacePredictionModel prediction) async {
          // calculate distance
          double distance = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            prediction.geometry!.location!.lat!,
            prediction.geometry!.location!.lng!,
          );

          Map<String, dynamic> placeWithDistance = {
            ...prediction.toJson(),
            ...{"distance": distance},
          };

          sortedResultsList.add(PlacePredictionModel.fromJson(placeWithDistance));

          return;
        },
      ),
    );

    sortedResultsList.sort((a, b) => a!.distance!.compareTo(b!.distance!));

    if (sortedResultsList.isNotEmpty) {
      // Filter for establishments first
      PlacePredictionModel? establishment = sortedResultsList.firstWhere(
        (place) => (place!.types ?? []).contains('establishment'),
        orElse: () => null,
      );
      // If no establishment is found, use the first result as fallback
      return establishment ?? sortedResultsList.first;
    } else {
      return null;
    }
  }
  return null;
}

Future<String> _getPlaceIdFromCoordinates(double latitude, double longitude) async {
  String apiKey = Properties.googleApiKey;

  Map<dynamic, dynamic> cachePlaceMap = {};
  String cacheKey = "$latitude$longitude";
  cachePlaceMap = await getHive("placeCordinates") ?? {};

  if (cachePlaceMap.containsKey(cacheKey)) {
    final jsonResponse = cachePlaceMap[cacheKey];
    if (jsonResponse['results'] != null && jsonResponse['results'].isNotEmpty) {
      return jsonResponse['results'][0]['place_id'];
    } else {
      throw Exception('No results found for the given coordinates.');
    }
  } else {
    final response = await http
        .get(Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey'));

    if (response.statusCode == 200) {
      // caching data
      final jsonResponse = jsonDecode(response.body);
      cachePlaceMap[cacheKey] = jsonResponse;
      await saveHive(key: "placeCordinates", data: cachePlaceMap);

      if (jsonResponse['results'] != null && jsonResponse['results'].isNotEmpty) {
        return jsonResponse['results'][0]['place_id'];
      } else {
        throw Exception('No results found for the given coordinates.');
      }
    } else {
      throw Exception('Failed to load place ID from coordinates');
    }
  }
}

Future<PlaceDetailsModel> getPlaceDetailsFromCoordinates(double latitude, double longitude) async {
  String placeId = await _getPlaceIdFromCoordinates(latitude, longitude);
  return await getPlaceDetails(placeId, LatLng(latitude, longitude));
}

// Variables to store the last location and threshold
LatLng? _lastPlaceDetailsRequestLocation;
const double _minDistanceThreshold = 100.0; // Minimum distance in meters to make a new API call
PlaceDetailsModel? _placeDetailsModel;

Future<PlaceDetailsModel> getPlaceDetailsFromCoordinatesHomepage(double latitude, double longitude) async {
  LatLng currentLocation = LatLng(latitude, longitude);

  // Check if there's a previous location and compute the distance
  if (_lastPlaceDetailsRequestLocation != null) {
    final double distance = Geolocator.distanceBetween(
      _lastPlaceDetailsRequestLocation!.latitude,
      _lastPlaceDetailsRequestLocation!.longitude,
      currentLocation.latitude,
      currentLocation.longitude,
    );

    // If the distance is less than the threshold, return the previous result to avoid unnecessary API call
    if (distance < _minDistanceThreshold) {
      return Future.value(_placeDetailsModel); // Return a cached/empty result or handle accordingly
    }
  }

  // If the distance is greater than the threshold, make a new API call
  String placeId = await _getPlaceIdFromCoordinates(latitude, longitude);
  PlaceDetailsModel placeDetails = await getPlaceDetails(placeId, LatLng(latitude, longitude));
  _placeDetailsModel = placeDetails;

  // Update the last requested location
  _lastPlaceDetailsRequestLocation = currentLocation;

  return placeDetails;
}

Future<int> getDurationInSeconds(List<LatLng> locations) async {
  String apiKey = Properties.googleApiKey;

  // Prepare waypoints in the required format, excluding the first (origin) and last (destination)
  String waypoints = locations
      .skip(1)
      .take(locations.length - 2)
      .map((LatLng point) => '${point.latitude},${point.longitude}')
      .join('|');

  final url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=${locations.first.latitude},${locations.first.longitude}&destination=${locations.last.latitude},${locations.last.longitude}&waypoints=$waypoints&key=$apiKey";

  final response = await http.get(Uri.parse(url));
  final jsonResponse = jsonDecode(response.body);

  if (jsonResponse["status"] != "OK") {
    throw Exception("Error fetching duration: ${jsonResponse['status']}");
  }

  final legs = jsonResponse["routes"][0]["legs"] as List;

  // Sum up the duration from each leg, ensuring each is treated as an integer
  final totalDuration = legs.map<int>((leg) => leg["duration"]["value"] as int).reduce((a, b) => a + b);

  return totalDuration;
}

Future<TripEstimateModel?> getTripEstimate(
  List<LatLng> locations,
  String geofenceId, {
  List<String>? stopGeofendIds,
  List<LatLng>? stopsLocations,
}) async {
  double totalDistanceInKm = 0.0;

  debugPrint("==> locations $locations");
  debugPrint("==> geofenceId $geofenceId");
  debugPrint("==> stopGeofendIds $stopGeofendIds");
  debugPrint("==> stopsLocations $stopsLocations");

  // Combine main route locations and stops into one list for road distance calculation
  List<LatLng> allLocations = [...locations];
  if (stopsLocations != null && stopsLocations.isNotEmpty) {
    allLocations.addAll(stopsLocations);
  }

  // Calculate road distance and duration using a Directions API
  final directionsResponse = await getRoadDistanceAndDuration(allLocations);

  if (directionsResponse == null) {
    debugPrint("Failed to get road distance and duration.");
    return null;
  }

  totalDistanceInKm = directionsResponse["totalDistanceInKm"];
  double totalDurationInMinutes = directionsResponse["totalDurationInMinutes"];

  debugPrint("==> totalRoadDistanceInKm $totalDistanceInKm");
  debugPrint("==> totalDurationInMinutes $totalDurationInMinutes");

  List<Map<String, dynamic>> stopsGeofencesList = [];

  if (stopGeofendIds != null && stopsLocations != null && stopGeofendIds.isNotEmpty) {
    for (int i = 0; i < stopGeofendIds.length; i++) {
      double stopDistanceInKm = 0.0;
      double stopDurationInMinutes = 0.0;

      if (i < stopsLocations.length) {
        final stopResponse = await getRoadDistanceAndDuration([
          locations.last, // Start from the last main location
          stopsLocations[i]
        ]);

        if (stopResponse != null) {
          stopDistanceInKm = stopResponse["totalDistanceInKm"];
          stopDurationInMinutes = stopResponse["totalDurationInMinutes"];
        }
      }

      Map<String, dynamic> stopsGeofenceMap = {
        "km": stopDistanceInKm,
        "min": stopDurationInMinutes,
        "geofenceId": stopGeofendIds[i],
      };
      debugPrint("==> stopsGeofenceMap $stopsGeofenceMap");
      stopsGeofencesList.add(stopsGeofenceMap);
    }

    debugPrint("==> stopsGeofencesList $stopsGeofencesList");
  }

  Map<String, dynamic> httpResult = await httpChecker(
    httpRequesting: () => httpRequesting(
      endPoint: HttpServices.noEndPoint,
      method: HttpMethod.post,
      httpPostBody: {
        "action": HttpActions.tripEstimate,
        "stops": json.encode(
          [
            ...stopsGeofencesList,
            {
              "km": totalDistanceInKm.toString(),
              "min": totalDurationInMinutes.toString(),
              "geofenceId": geofenceId,
            },
          ],
        ),
      },
    ),
  );

  logStatement("==> estimate $httpResult");

  if (httpResult["ok"]) {
    TripEstimateModel model = TripEstimateModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
      duration: (totalDurationInMinutes * 60).toStringAsFixed(0), // min in seconds
      distanceKm: totalDistanceInKm.toString(),
    );
    return model;
  } else {
    return null;
  }
}

// Helper function to get road distance and duration
Future<Map<String, dynamic>?> getRoadDistanceAndDuration(List<LatLng> waypoints) async {
  try {
    String apiKey = Properties.googleApiKey;

    // Prepare request to Google Directions API or similar service
    final origin = waypoints.first;
    final destination = waypoints.last;
    final waypointsQuery = waypoints.skip(1).take(waypoints.length - 2).map((waypoint) {
      return '${waypoint.latitude},${waypoint.longitude}';
    }).join('|');

    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=$waypointsQuery&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "OK") {
        double totalDistanceInKm = 0.0;
        double totalDurationInMinutes = 0.0;

        for (var leg in data["routes"].first["legs"]) {
          totalDistanceInKm += leg["distance"]["value"] / 1000.0; // Convert meters to km
          totalDurationInMinutes += leg["duration"]["value"] / 60.0; // Convert seconds to minutes
        }

        return {
          "totalDistanceInKm": totalDistanceInKm,
          "totalDurationInMinutes": totalDurationInMinutes,
        };
      }
    }
    debugPrint("Error in Directions API response: ${response.body}");
  } catch (e) {
    debugPrint("Error fetching road distance and duration: $e");
  }
  return null;
}

// Helper function to generate the static map URL
String _buildStaticMapUrl({
  required double centerLat,
  required double centerLng,
  required String apiKey,
  required double startLat,
  required double startLng,
  required double endLat,
  required double endLng,
  String? encodedPolyline, // Optional encoded polyline
  List<LatLng>? pathCoordinates, // Optional list of path coordinates
}) {
  // Construct the markers part of the URL
  String markers = '&markers=color:red%7Clabel:A%7C$startLat,$startLng'
      '&markers=color:blue%7Clabel:B%7C$endLat,$endLng';

  // Construct the path part of the URL
  String path;
  if (encodedPolyline != null) {
    path = '&path=enc:$encodedPolyline'; // Use encoded polyline if available
  } else if (pathCoordinates != null) {
    String polylinePath = pathCoordinates.map((LatLng coordinate) {
      return '${coordinate.latitude},${coordinate.longitude}';
    }).join('|');
    path = '&path=color:0xFF8652FD|weight:5|$polylinePath'; // Use direct coordinates if no encoded polyline
  } else {
    path = ''; // No path to include
  }

  // Construct the full static map URL
  return 'https://maps.googleapis.com/maps/api/staticmap'
      '?center=$centerLat,$centerLng'
      '&zoom=13'
      '&size=600x300'
      '$markers'
      '$path'
      '&key=$apiKey';
}

Future<String> generateStaticMapUrl({
  required List<LatLng> pathCoordinates,
  required double startLat,
  required double startLng,
  required double endLat,
  required double endLng,
}) async {
  String apiKey = Properties.googleApiKey;

  // Calculate center latitude and longitude based on start and end points
  double centerLat = (startLat + endLat) / 2;
  double centerLng = (startLng + endLng) / 2;

  // Prepare waypoints in the required format, excluding the first (origin) and last (destination)
  String waypoints = pathCoordinates
      .skip(1)
      .take(pathCoordinates.length - 2)
      .map((LatLng point) => '${point.latitude},${point.longitude}')
      .join('|');

  // Step 1: Get Directions API response to fetch encoded polyline
  String directionsUrl =
      'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&waypoints=$waypoints&key=$apiKey';

  // Step 2: Make the HTTP request to fetch directions data
  final response = await http.get(Uri.parse(directionsUrl));

  if (response.statusCode == 200) {
    // Step 3: Parse the response to get the encoded polyline
    final Map<String, dynamic> data = json.decode(response.body);

    if (data['routes'] != null && data['routes'].isNotEmpty) {
      String encodedPolyline = data['routes'][0]['overview_polyline']['points'];

      // Step 4: Use the encoded polyline to generate the static map URL
      return _buildStaticMapUrl(
        centerLat: centerLat,
        centerLng: centerLng,
        apiKey: apiKey,
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
        encodedPolyline: encodedPolyline, // Pass the encoded polyline
      );
    } else {
      // No routes found, fallback to using direct coordinates
      return _buildStaticMapUrl(
        centerLat: centerLat,
        centerLng: centerLng,
        apiKey: apiKey,
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
        pathCoordinates: pathCoordinates, // Pass direct coordinates
      );
    }
  } else {
    // Failed to get directions, fallback to using direct coordinates
    return _buildStaticMapUrl(
      centerLat: centerLat,
      centerLng: centerLng,
      apiKey: apiKey,
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      pathCoordinates: pathCoordinates, // Pass direct coordinates
    );
  }
}
