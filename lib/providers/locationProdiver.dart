import 'package:geolocator/geolocator.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';

Position? cachedLocation;
class LocationProvider {
  
  Future<Position> getCurrentLocation() async {
    // If location is already cached, return it
    // Map? cachePosition = await getHive("currentLocation");
    // if (cachePosition != null) {
    //   cachedLocation = Position.fromMap(cachePosition);
    // }
    if (cachedLocation != null) {
      return cachedLocation!;
    }

    // Get current location and cache it
    cachedLocation = await Geolocator.getCurrentPosition();
    saveHive(key: "currentLocation", data: cachedLocation!.toJson());
    return cachedLocation!;
  }

  // To simulate updating the location, you can set a method to reset cache
  void updateLocation(Position newLocation) {
    cachedLocation = newLocation;
  }

  // This can be used when you want to listen to location updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream();
  }
}
