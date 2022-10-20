import 'dart:ffi';

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

  UploadPost({
    required this.name,
    required this.url,
    required this.latitude,
    required this.longitude
  });

  factory UploadPost.fromJson(Map<String, dynamic> json) {
    return UploadPost(
      name: json['name'],
      url: json['url'],
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }
}