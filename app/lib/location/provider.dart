import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location.dart';

// ウィジェット間でデータを共有するためのクラス
class LocationProvider with ChangeNotifier {
  Position position = Position(
      latitude: 0,
      longitude: 0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  LocationSettings locationSettings =
      LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0);
  LocationProvider() {
    determinePosition().then((value) => position = value);
    // .then((value) => listenPosition(), onError: (error) => print(error));
  }
  void initState() {
    determinePosition().then((value) => position = value);
  }

  void updatePosition() {
    determinePosition().then((value) {
      position = value;
      notifyListeners();
    });
  }

  void listenPosition() {
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      this.position = position;
      notifyListeners();
    });
  }
}
