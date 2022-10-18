import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'location.dart';

// ウィジェット間でデータを共有するためのクラス
class LocationProvider with ChangeNotifier {
  Position? position;
  LocationSettings locationSettings =
      LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0);
  LocationProvider() {
    determinePosition()
        .then((value) => position = value)
        .then((value) => listenPosition(), onError: (error) => print(error));
  }

  void listenPosition() {
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      this.position = position;
      notifyListeners();
    });
  }
}
