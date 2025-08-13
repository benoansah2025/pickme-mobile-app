import 'dart:math';

class DummyCordinateGenerator {
  final double latitude;
  final double longitude;
  final double bearing;

  DummyCordinateGenerator(this.latitude, this.longitude, this.bearing);

  @override
  String toString() {
    return '($latitude, $longitude)';
  }
}

List<DummyCordinateGenerator> generateSurroundingCoordinates(double lat, double lon) {
  // Earth's radius in meters
  const double earthRadius = 6371000;

  // Distance in radians corresponding to 20 meters
  double distanceRadians = 250 / earthRadius;

  // Conversion factor: degrees to radians
  double toRadians = pi / 180.0;

  // Original coordinates
  DummyCordinateGenerator original = DummyCordinateGenerator(lat, lon, 0);

  // Calculate surrounding coordinates
  List<DummyCordinateGenerator> surroundingCoordinates = [];

  // Generate 5 coordinates: one at the original position and four in cardinal directions
  for (int i = 0; i < 5; i++) {
    double bearing = i * 90.0; // 0, 90, 180, 270 degrees

    double latRadians = lat * toRadians;
    double lonRadians = lon * toRadians;
    double bearingRadians = bearing * toRadians;

    double newLat =
        asin(sin(latRadians) * cos(distanceRadians) + cos(latRadians) * sin(distanceRadians) * cos(bearingRadians));
    double newLon = lonRadians +
        atan2(sin(bearingRadians) * sin(distanceRadians) * cos(latRadians),
            cos(distanceRadians) - sin(latRadians) * sin(newLat));

    // Convert back to degrees
    double newLatDegrees = newLat / toRadians;
    double newLonDegrees = newLon / toRadians;

    surroundingCoordinates.add(DummyCordinateGenerator(newLatDegrees, newLonDegrees, bearing));

    // Increase the distance for the next coordinate by 250 meters
    distanceRadians += 250 / earthRadius;
  }

  return surroundingCoordinates;
}

// void main() {
//   double initialLat = 51.5074; // example latitude
//   double initialLon = -0.1278; // example longitude

//   List<DummyCordinateGenerator> result = generateSurroundingCoordinates(initialLat, initialLon);

//   print('Original Coordinate: (${initialLat.toStringAsFixed(4)}, ${initialLon.toStringAsFixed(4)})');
//   print('Surrounding Coordinates:');
//   for (var coord in result) {
//     print('(${coord.latitude.toStringAsFixed(4)}, ${coord.longitude.toStringAsFixed(4)})');
//   }
// }
