import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:app/handle_api/handle.dart';
import 'package:app/model.dart';

class Plant {
  final int id;
  final String name;
  final String detail;
  final String url;
  final LocationData location;
  final double distance;
  final String timestamp;
  Plant(
      {required this.id,
      required this.name,
      this.detail = "",
      required this.url,
      required this.location,
      this.distance = 0.0,
      this.timestamp = ""});

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
        name: json['name'] ?? "",
        detail: json['detail'] ?? "",
        url: json['url'] ?? "",
        location: LocationData.fromMap({
          "latitude": json['latitude'] ?? 0.0,
          "longitude": json['longitude'] ?? 0.0,
        }),
        id: json['id'] ?? 0,
        distance: json['distance'] ?? 0.0,
        timestamp: json['timestamp'] ?? "");
  }
}

class Plants {
  late List<Plant> plants_list;
  Plants({required this.plants_list});
  factory Plants.fromJson(List<dynamic> json) {
    List<Plant> plants = [];
    for (var plant in json) {
      if (!plant.containsKey("latitude") || !plant.containsKey("longitude")) {
        plant["location"] = {
          "latitude": 0.0,
          "longitude": 0.0,
        };
      }
      plants.add(Plant.fromJson(plant));
    }
    return Plants(plants_list: plants);
  }

  void update_plants(LocationData position) async {
    getNearPlant(position).then((value) {
      plants_list = value.plants_list;
    }).catchError((e) {
      print("CLASS : Plants, METHOD : update_plants");
      print(e);
    });
  }

  List<Plant> get_plants() {
    return this.plants_list;
  }

  List<String> get_urls() {
    List<String> urls = [];
    for (var plant in this.plants_list) {
      urls.add(plant.url);
    }
    return urls;
  }

  List<UploadPost> plants2posts() {
    List<UploadPost> posts = [];
    for (var plant in this.plants_list) {
      posts.add(UploadPost(
          name: plant.name,
          url: plant.url,
          latitude: plant.location.latitude!,
          longitude: plant.location.longitude!,
          detail: plant.detail));
    }
    return posts;
  }

  void showDetail(BuildContext context, UploadPost post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(post.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                post.url,
                width: 200,
                height: 200,
              ),
              Text(post.detail),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("return"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Set<Marker> plants2markers(context) {
    Set<Marker> markers = Set<Marker>();
    for (var plant in this.plants2posts()) {
      markers.add(Marker(
          markerId: MarkerId(plant.name),
          position: LatLng(plant.latitude, plant.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () {
            showDetail(context, plant);
          }));
    }
    return markers;
  }
}
