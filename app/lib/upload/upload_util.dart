import 'package:app/handle_api/gcs_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadInfo {
  int id = 0;
  String name;
  String hash;
  double latitude;
  double longitude;
  List<String> tags;

  UploadInfo(
      {required this.id,
      required this.name,
      required this.hash,
      required this.latitude,
      required this.longitude,
      required this.tags});
  factory UploadInfo.fromJson(Map<String, dynamic> json) {
    return UploadInfo(
        id: json['id'],
        name: json['name'],
        hash: json['hash'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        tags: json['tags']);
  }
  // convert to json
  Map<String, dynamic> toJson() => {
        'plant_id': id,
        'name': name,
        'hash': hash,
        'latitude': latitude,
        'longitude': longitude,
        'tags': tags,
      };
}

Future<void> upload_post(UploadInfo info) async {
  String url = "https://${dotenv.get('API_IP')}/api/post/upload";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode(info.toJson());
  try {
    http.Response response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('投稿に失敗しました');
    }
  } catch (e) {
    throw Exception('投稿に失敗しました');
  }
}

// 画像のアップロードをする関数
Future<void> uploadImage(image, hash) async {
  try {
    await upload_to_gcs(image, hash);
  } catch (e) {
    throw Exception('画像のアップロードに失敗しました');
  }
}

// 画像の削除をする関数
Future<void> delete_post(String hash) async {
  try {
    await delete_from_gcs(hash);
  } catch (e) {
    throw Exception('画像の削除に失敗しました');
  }
}

// VisionAIにurlを投げて名前を返す
Future<dynamic> plant_identify(String hash) async {
  try {
    http.Response resp = await http.get(Uri.parse(
        'http://${dotenv.get('API_IP')}/api/plant_identify?hash=${hash}'));
    if (resp.statusCode != 200) {
      throw Exception('植物の認識に失敗しました');
    }
    return json.decode(resp.body);
  } catch (e) {
    throw Exception('植物の認識に失敗しました');
  }
}

// 画像をアルバムから選択する関数
Future<File> image_picker_gallery() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image == null) {
    throw Exception('画像の取得に失敗しました');
  }
  return File(image.path);
}

// 写真を撮影する関数
Future<File> image_picker_camera() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  if (image == null) {
    throw Exception('画像の取得に失敗しました');
  }
  return File(image.path);
}
