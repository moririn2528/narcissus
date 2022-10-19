import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'location.dart';

// ウィジェット間でデータを共有するためのクラス
class LocationProvider with ChangeNotifier {
  Position? position;
  LocationProvider() {
    determinePosition()
        .then((value) => position = value)
        .then((value) => listenPosition(), onError: (error) => print(error));
  }

  void listenPosition() {
    Geolocator.getPositionStream().listen((Position position) {
      this.position = position;
      notifyListeners();
    });
  }
}
