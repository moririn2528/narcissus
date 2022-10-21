import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

Future<void> upload_to_gcs(image, hash) async {
  // Initialize the gcs service client
  final client = await auth.clientViaMetadataServer();
  final storage = Storage(client, "D2202");
  final b = storage.bucket('test-bucket');
  b.writeBytes(hash, image);
  // Upload image to GS bucket
}
