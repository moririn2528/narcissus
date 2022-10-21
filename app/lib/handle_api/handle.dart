import 'dart:convert';
import 'Dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

Future<List<dynamic>> fetchTest() async {
  late List data = [];
  try {
    final response =
        await http.get(Uri.parse("http://${dotenv.get('API_IP')}/api/plant"));
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

Future<List> getNearPlant(Position position, {double length = 1000}) async {
  var output = [];
  await http
      .get(Uri.parse(
          'http://${dotenv.get('API_IP')}/api/near?latitude=${position.latitude}&longitude=${position.longitude}&length=${length}'))
      .then((value) {
    if (value.statusCode == 200) {
      final data = jsonDecode(value.body);
      if (data["IsEmpty"] == 0) {
        output = data["Datas"];
      }
    }
  }, onError: (e) {
    print(e);
  });
  return output;
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

Future<List> searchPlant(List<String> tag) async {
  final String url = 'http://${dotenv.get('API_IP')}/api/search';
  List<dynamic> plants = [];
  final Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  final Map<String, dynamic> body = {'tag': tag};
  http.Response response;
  http
      .post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(body),
  )
      .then((value) {
    response = value;
    plants = jsonDecode(response.body);
  });

  return plants;
}
