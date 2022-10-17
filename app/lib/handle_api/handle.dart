import 'dart:convert';
import 'Dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../location/location.dart';

Future<List<dynamic>> fetchTest() async {
  late List data = [];
  try {
    final response = await http.get(
        Uri.parse("http://${dotenv.get('API_IP')}/api/plant"),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      data = json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (err) {
    print(err);
  }
  return data;
}

Future<List> getNearPlant() async {
  await http.get(Uri.parse('http://${dotenv.get('API_IP')}/api/near')).then(
      (value) {
    if (value.statusCode == 200) {
      final List data = jsonDecode(value.body);
      if (data.isNotEmpty) {
        return data;
      }
    }
  }, onError: (e) {
    print(e);
  });
  return [];
}

Future<List> getTags() async {
  final response =
      await http.get(Uri.parse('http://${dotenv.get('API_IP')}/api/tag'));
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data;
  } else {
    throw Exception('Failed to load tags');
  }
}
