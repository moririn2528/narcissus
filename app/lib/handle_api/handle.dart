import 'dart:convert';
import 'Dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:app/local_plant/plants.dart';

Future<List<dynamic>> fetchTest() async {
  late List data = [];
  try {
    final response =
        await http.get(Uri.parse("${dotenv.get('API_IP')}/api/plant"));
    if (response.statusCode == 200) {
      data = json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (err) {
    print("CLASS: HANDLE_API, FUNCTION: fetchTest");
  }
  return data;
}

Future<Plants> getNearPlant(LocationData position,
    {double length = 1000}) async {
  http.Response response;
  Plants output = Plants(plants_list: []);
  try {
    response = await http.get(Uri.parse(
        'http://${dotenv.get('API_IP')}/api/near?latitude=${position.latitude}&longitude=${position.longitude}&length=$length'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      output = Plants.fromJson(data["Datas"]);
    } else {
      throw Exception('Failed to load plants');
    }
  } catch (err) {
    print("CLASS: HANDLE_API, FUNCTION: getNearPlant");
  }
  return output;
}

Future<Tags> getTags() async {
  final response =
      await http.get(Uri.parse('http://${dotenv.get('API_IP')}/api/tag'));
  if (response.statusCode == 200) {
    final data = Tags.fromJson(jsonDecode(response.body));
    return data;
  } else {
    throw Exception('Failed to load tags');
  }
}

Future<Plants> searchPlant(List<int> tag) async {
  String url = 'http://${dotenv.get('API_IP')}/api/search';
  if (tag.length > 0) {
    url += "?optional_tags=" + tag.join(',');
  }
  Plants plants = Plants(plants_list: []);
  http.Response response;
  print(url);
  try {
    response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null) {
        return plants;
      }
      plants = Plants.fromJson(data);
      print("Number of plants: ${plants.plants_list.length}");
    } else {
      print("CLASS: HANDLE_API, FUNCTION: searchPlant");
      throw Exception('Failed to load plants');
    }
  } catch (err) {
    print("CLASS: HANDLE_API, FUNCTION: searchPlant");
    print(err);
  }
  return plants;
}

class Tag {
  final String name;
  final int id;
  Tag({required this.name, required this.id});
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(name: json['name'], id: json['id']);
  }
}

class Tags {
  final List<Tag> tags;
  Tags({required this.tags});
  factory Tags.fromJson(List<dynamic> json) {
    List<Tag> tags = [];
    for (var i = 0; i < json.length; i++) {
      tags.add(Tag.fromJson(json[i]));
    }
    return Tags(tags: tags);
  }
  List<String> get tags_list {
    List<String> output = [];
    for (var i = 0; i < tags.length; i++) {
      output.add(tags[i].name);
    }
    return output;
  }
}
