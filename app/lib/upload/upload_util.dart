import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model.dart';
import 'package:firebase_core/firebase_core.dart';

// TODO
Future<void> upload_post(UploadInfo info) async {
  String url = "https://httpbin.org/post";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({
    'name': info.name,
    'latitude': info.latitude,
    'longitude': info.longitude,
    'hash': info.hash,
    'tags': info.tags,
  });

  http.Response resp =
      await http.post(Uri.parse(url), headers: headers, body: body);
  if (resp.statusCode != 200) {
    return;
  } else {
    throw Exception('投稿の送信に失敗しました');
  }
}

// 画像のアップロードをする関数
// TODO
Future<String> uploadImage(image) async {
  return "";
}

// VisionAIにurlを投げて名前を返す
// TODO
Future<String> sendVisionAI(hash) async {
  // ここでVisionAIにURLを送る
  return "";
}
