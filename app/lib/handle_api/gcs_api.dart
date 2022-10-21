// TODO
import 'package:firebase_storage/firebase_storage.dart';

Future<void> upload_to_gcs(image, hash) async {
  final storage =
      FirebaseStorage.instanceFor(bucket: "gs://narcissus-364913.appspot.com");
  final ref = storage.ref().child(hash + ".jpg");
  await ref.putFile(image);
}

Future<void> delete_from_gcs(hash) async {
  await Future.delayed(Duration(seconds: 10));
  final storage =
      FirebaseStorage.instanceFor(bucket: "gs://narcissus-364913.appspot.com");
  final ref = storage.ref().child(hash + ".jpg");
  await ref.delete();
}
