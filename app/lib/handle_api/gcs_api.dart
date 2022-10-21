// TODO
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> upload_to_gcs(image, hash) async {
  final storage = FirebaseStorage.instanceFor(bucket: dotenv.get("GCS_IP"));
  final ref = storage.ref().child("upload-figure/${hash}.jpg");
  await ref.putFile(image);
}

Future<void> delete_from_gcs(hash) async {
  await Future.delayed(Duration(seconds: 10));
  final storage = FirebaseStorage.instanceFor(bucket: dotenv.get("GCS_IP"));
  final ref = storage.ref().child("upload-figure/${hash}.jpg");
  await ref.delete();
}
