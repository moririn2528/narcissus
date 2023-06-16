import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

// ウィジェット間でデータを共有するためのクラス
LocationData initialPosition = LocationData.fromMap({
  "latitude": 0.0,
  "longitude": 0.0,
});

class LocationState {
  final Location location = Location();
  LocationData position = initialPosition;
  LocationPermission permissionStatus = LocationPermission.denied;
  bool isPermissionGranted = false;

  Future<void> updatePosition() async {
    try {
      position = await location.getLocation();
      print("Position updated");
      print("latitude: ${position.latitude}, longitude: ${position.longitude}");
    } catch (e) {
      print("CLASS : LocationState, METHOD : updatePosition");
      position = LocationData.fromMap({
        "latitude": 0,
        "longitude": 0,
      });
    }
  }

  void set_background_mode() {
    location.enableBackgroundMode(enable: true);
  }

  Future<void> set_permission() async {
    await Geolocator.requestPermission().then((value) {
      permissionStatus = value;
      isPermissionGranted = value == LocationPermission.always ||
          value == LocationPermission.whileInUse;
    });
    return;
  }
}
