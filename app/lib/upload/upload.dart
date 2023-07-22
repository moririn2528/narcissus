import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/util/snackbar.dart';
import 'package:app/upload/upload_util.dart';
import 'package:app/upload/check_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/handle_api/handle.dart';
import 'package:app/location_state/location_state.dart';
import 'package:app/handle_api/gcs_api.dart';
import 'dart:io';
import 'package:app/util/circle.dart';

class UploadPage extends StatefulWidget {
  final LocationState locationState;
  UploadPage({required this.locationState});
  @override
  State<UploadPage> createState() => UploadPageState();
}

class UploadPageState extends State<UploadPage> {
  @override
  // two buttons to get image from camera or gallery
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // get image from camera
                final status = await Permission.camera.request();
                if (status.isGranted) {
                  try {
                    upload_navigation_camera();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      redsnackbar('カメラの起動に失敗しました'),
                    );
                  }
                } else {
                  if (validate()) {
                    // show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      redsnackbar('カメラの使用が許可されていません'),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      redsnackbar('位置情報を有効にしてください'),
                    );
                  }
                }
              },
              child: const Text('カメラから投稿'),
            ),
            ElevatedButton(
              onPressed: () async {
                // get image from gallery
                final status = await Permission.storage.request();
                if (validate()) {
                  try {
                    upload_navigation_gallery();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      redsnackbar('ギャラリーの起動に失敗しました'),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    redsnackbar('位置情報を有効にしてください'),
                  );
                }
              },
              child: const Text('アルバムから投稿'),
            ),
          ],
        ),
      ),
    );
  }

  // get identified tags from image
  Future<List<String>> analize_plant(File image) async {
    List<String> tags = [];
    String random_hash = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await uploadImage(image, random_hash);
      tags = await plant_identify(random_hash)
          .then((value) => value['identifies']);
      await delete_post(random_hash);
    } catch (e) {
      delete_post(random_hash);
      ScaffoldMessenger.of(context).showSnackBar(
        redsnackbar('画像の解析に失敗しました'),
      );
    }
    return tags;
  }

  void upload_navigation_camera() async {
    String random_hash = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      // get image from camera
      final File image = await image_picker_camera();
      // showWaitingDialog(context);
      // get identified tags from image

      // await upload_to_gcs(image, random_hash);
      // List<String> names = await analize_plant(image);
      List<String> names = [];
      // get all tags
      Tags tags = await getTags();
      // await delete_post(random_hash);
      // Navigator.pop(context);
      // move to check image page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckimagePage(
            image: image,
            candidate_tags: tags.tags_list,
            candidate_names: names,
            locationState: widget.locationState,
          ),
        ),
      );
    } catch (e) {
      await delete_post(random_hash);
      Navigator.pop(context);
      throw Exception('カメラの起動に失敗しました');
    }
  }

  void upload_navigation_gallery() async {
    String random_hash = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      // get image from gallery
      final File image = await image_picker_gallery();
      // showWaitingDialog(context);
      // get identified tags from image

      // upload_to_gcs(image, random_hash);
      // List<String> names = await analize_plant(image);
      List<String> names = [];
      // get all tags
      Tags tags = await getTags();
      // await delete_from_gcs(random_hash);
      // Navigator.pop(context);
      // move to check image page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckimagePage(
            image: image,
            candidate_tags: tags.tags_list,
            candidate_names: names,
            locationState: widget.locationState,
          ),
        ),
      );
    } catch (e) {
      await delete_post(random_hash);
      Navigator.pop(context);
      throw Exception('ギャラリーの起動に失敗しました');
    }
  }

  bool validate() {
    if (widget.locationState.position == null ||
        widget.locationState.position.latitude == 0 ||
        widget.locationState.position.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        redsnackbar('位置情報を有効にしてください'),
      );
      return false;
    }
    return true;
  }
}
