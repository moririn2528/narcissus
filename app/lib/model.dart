import 'dart:ffi';
import 'dart:io';

class Test {
  final int id;
  final String name;
  final String hash;

  Test({required this.id, required this.name, required this.hash});

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      name: json['name'],
      hash: json['hash'],
    );
  }
}

class UploadPost {
  final String name;
  final String url;
  final double latitude;
  final double longitude;
  final String detail;

  UploadPost(
      {required this.name,
      required this.url,
      required this.latitude,
      required this.longitude,
      required this.detail});

  factory UploadPost.fromJson(Map<String, dynamic> json) {
    return UploadPost(
        name: json['name'],
        url: json['url'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        detail: json['detail']
    );
  }
}

class UploadInfo {
  List<String> candidates = [];
  String name;
  final String hash;
  File image = File("/assets/images/default.png");
  final double latitude;
  final double longitude;
  List<String> tags;

  UploadInfo(
      {required this.candidates,
      required this.name,
      required this.hash,
      required this.image,
      required this.latitude,
      required this.longitude,
      required this.tags});

  factory UploadInfo.fromJson(Map<String, dynamic> json) {
    return UploadInfo(
        candidates: json['canidates'],
        name: json['name'],
        hash: json['url'],
        image: json['image'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        tags: json['tags']);
  }
}
