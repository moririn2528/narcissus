import 'dart:developer';
import 'dart:async';
import 'package:app/handle_api/gcs_api.dart';
import '../model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../error_dialog/error_dialog.dart';
import '../search/search.dart';
import '../search/provider.dart';
import './upload_util.dart';
import '../location/location.dart';
import 'dart:io';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("アップロード"),
      ),
      body: UploadGroup(),
    );
  }
}

class UploadGroup extends StatefulWidget {
  const UploadGroup({Key? key}) : super(key: key);

  @override
  _UploadGroupState createState() => _UploadGroupState();
}

class _UploadGroupState extends State<UploadGroup> {
  @override
  Widget build(BuildContext context) {
    // UIの部分はここに書く。
    return Column(children: [
      ElevatedButton(
          onPressed: (() => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return FormPage(func: getImageFromCamera());
                },
              ))),
          child: const Text("カメラからアップロード")),
// ライブラリからの選択
      ElevatedButton(
          onPressed: (() => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return FormPage(func: getImageFromLibrary());
                },
              ))),
          child: const Text('ライブラリ写真から選択')),
    ]);
  }
}

class FormPage extends StatefulWidget {
  final Future<Widget> func;
  FormPage({required this.func});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.func,
      builder: ((context, snapshot) {
        if (snapshot.hasError ||
            snapshot.hasData == false ||
            snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data!;
        } else {
          return Error_Dialog("エラー", "写真の読み込み時にエラーが発生しました。");
        }
      }),
    );
  }
}

Future<Widget> getImageFromCamera() async {
  String name;
  UploadInfo info;
  Future<dynamic> picked;
  File image = File("/assets/images/default.png");
  String hash = DateTime.now()
      .toString()
      .replaceAll(" ", "")
      .replaceAll(":", "")
      .replaceAll(".", "");
  if (await Permission.camera.request().isGranted &&
      await Permission.location.request().isGranted) {
    picked = ImagePicker().pickImage(source: ImageSource.camera).then((value) {
      try {
        // 画像をアップロード
        image = File(value!.path);
        uploadImage(image, hash);
        name = sendVisionAI(hash);
        determinePosition().then((value) {
          info = UploadInfo(
              name: name,
              hash: hash,
              image: image,
              latitude: value.latitude,
              longitude: value.longitude,
              tags: []);
          return UploadForm(info);
        });
      } catch (e) {
        delete_from_gcs(hash);
      }
    });
  } else {
    return Error_Dialog("カメラ", "カメラの使用が許可されていません。");
  }
  return Error_Dialog("画像のアップロードに失敗しました", "時間をおいてもう一度やり直してください");
}

Future<Widget> getImageFromLibrary() async {
  String name;
  UploadInfo info;
  Future<dynamic> picked;
  File image = File("/assets/images/default.png");
  String hash = DateTime.now()
      .toString()
      .replaceAll(" ", "")
      .replaceAll(":", "")
      .replaceAll(".", "");
  if (await Permission.camera.request().isGranted &&
      await Permission.location.request().isGranted) {
    picked = ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      try {
        // 画像をアップロード
        image = File(value!.path);
        uploadImage(image, hash);
        name = sendVisionAI(hash);
        determinePosition().then((value) {
          info = UploadInfo(
              name: name,
              hash: hash,
              image: image,
              latitude: value.latitude,
              longitude: value.longitude,
              tags: []);
          return UploadForm(info);
        });
      } catch (e) {
        delete_from_gcs(hash);
      }
    });
  } else {
    return Error_Dialog("ライブラリ", "ライブラリの使用が許可されていません。");
  }
  return Error_Dialog("画像のアップロードに失敗しました", "時間をおいてもう一度やり直してください");
}

class UploadForm extends StatelessWidget {
  UploadInfo info;

  UploadForm(this.info);

  @override
  Widget build(BuildContext context) {
    final SearchProvider searchProvider = SearchProvider();
    return Scaffold(
      appBar: AppBar(title: Text("アップロード")),
      body: Column(
        children: <Widget>[
          Center(
            child: info.image == null
                ? Text('No image selected.')
                : Image.file(info.image),
          ),
          Center(
            child: Row(
              children: [
                Text("植物名:"),
                TextFormField(
                  initialValue: info.name,
                  onChanged: (text) {
                    info.name = text;
                  },
                ),
              ],
            ),
          ),
          SearchGroup(
            searchProvider: searchProvider,
          ),
          OutlinedButton(
              onPressed: (() {
                // アップロード処理
                info.tags = searchProvider.keep_tags;
                showUploadingDialog(context, info);
              }),
              child: Text("アップロード")),
        ],
      ),
    );
  }
}

void showUploadingDialog(context, UploadInfo info) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("アップロード"),
          content: FutureBuilder(
            future: upload_post(info),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              try {
                if (snapshot.hasData) {
                  return Text("アップロードしました");
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              } catch (e) {
                return Text("アップロードに失敗しました、アプリを再起動してみてください\n" + e.toString());
              }
            },
          ),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("閉じる")),
          ],
        );
      });
}
