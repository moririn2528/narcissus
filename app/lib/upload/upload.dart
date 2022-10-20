import 'dart:developer';

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
  if (await Permission.camera.request().isGranted &&
      await Permission.location.request().isGranted) {
    var name;
    var image;
    var hash;
    try {
      await ImagePicker()
          .pickImage(source: ImageSource.camera)
          .then(
              // 画像をアップロード
              (value) => value!.readAsBytes().then((value) async {
                    image = value;
                    hash = await uploadImage(value);
                  }))
          .then((_) async {
        // VisionAIにURLを送る
        name = await sendVisionAI(hash);
      }).then((_) async {
        final position = await determinePosition();
        return UploadForm(
            image, name, hash, position.latitude, position.longitude);
      });
    } catch (e) {
      log(e.toString());
    }
  } else {
    return Error_Dialog("カメラ", "カメラの使用が許可されていません。");
  }
  return Error_Dialog("画像のアップロードに失敗しました", "時間をおいてもう一度やり直してください");
}

Future<Widget> getImageFromLibrary() async {
  if (await Permission.storage.request().isGranted &&
      await Permission.location.request().isGranted) {
    var name;
    var image;
    var hash;
    try {
      await ImagePicker()
          .pickImage(source: ImageSource.gallery)
          .then((value) => value!.readAsBytes().then((value) async {
                image = value;
                hash = await uploadImage(value);
              }))
          .then((_) async {
        // VisionAIにURLを送る
        name = await sendVisionAI(hash);
      }).then((_) async {
        final position = await determinePosition();
        return UploadForm(
            image, name, hash, position.latitude, position.longitude);
      });
    } catch (e) {
      log(e.toString());
    }
  } else {
    return Error_Dialog("ライブラリ", "ライブラリの使用が許可されていません。");
  }
  return Error_Dialog("画像のアップロードに失敗しました", "時間をおいてもう一度やり直してください");
}

class UploadForm extends StatelessWidget {
  File _image;
  String name;
  double latitude;
  double longitude;
  String hash;
  List<dynamic>? tags = [];

  UploadForm(this._image, this.name, this.hash, this.latitude, this.longitude);

  @override
  Widget build(BuildContext context) {
    final SearchProvider searchProvider = SearchProvider();
    return Scaffold(
      appBar: AppBar(title: Text("アップロード")),
      body: Column(
        children: <Widget>[
          Center(
            child: _image == null
                ? Text('No image selected.')
                : Image.file(_image),
          ),
          Center(
            child: Row(
              children: [
                Text("植物名:"),
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(
                    hintText: "植物名を入力してください",
                  ),
                  onChanged: (text) {
                    name = text;
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
                tags = searchProvider.keep_tags;
                showUploadingDialog(
                    context, name, latitude, longitude, hash, tags);
              }),
              child: Text("アップロード")),
        ],
      ),
    );
  }
}

void showUploadingDialog(context, String name, double latitude,
    double longitude, String hash, List<dynamic>? tags) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("アップロード"),
          content: FutureBuilder(
            future: upload_post(name, latitude, longitude, hash, tags),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Text("アップロードしました");
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
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
