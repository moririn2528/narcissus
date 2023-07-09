// TODO
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> upload_to_gcs(image, hash) async {
  try {
    final storage = FirebaseStorage.instance;
    await storage.ref().child("upload-figure/${hash}.jpg").putFile(image);
  } catch (e) {
    throw Exception('GCSへのアップロードに失敗しました');
  }
}

Future<void> delete_from_gcs(hash) async {
  try {
    final storage = FirebaseStorage.instance;
    await storage.ref().child("upload-figure/${hash}.jpg").delete();
  } catch (e) {
    throw Exception('GCSからの削除に失敗しました');
  }
}
