import 'dart:developer';
import 'dart:async';
import 'package:app/handle_api/gcs_api.dart';
import 'package:app/location/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
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
                  return FormPageCamera();
                },
              ))),
          child: const Text("カメラからアップロード")),
// ライブラリからの選択
      ElevatedButton(
          onPressed: (() => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return FormPageLibray();
                },
              ))),
          child: const Text('ライブラリ写真から選択')),
    ]);
  }
}

class FormPageLibray extends StatefulWidget {
  @override
  _FormPageLibraryState createState() => _FormPageLibraryState();
}

class _FormPageLibraryState extends State<FormPageLibray> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    return Container(
        child: FutureBuilder(
      future: getImageFromLibrary(locationProvider),
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
    ));
  }
}

class FormPageCamera extends StatefulWidget {
  @override
  _FormPageCameraState createState() => _FormPageCameraState();
}

class _FormPageCameraState extends State<FormPageLibray> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    return Container(
        child: FutureBuilder(
      future: getImageFromCamera(locationProvider),
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
    ));
  }
}

Future<Widget> getImageFromCamera(LocationProvider locationProvider) async {
  List<String> candidates = [];
  String name = "";
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
        sendVisionAI(hash).then((value) => candidates = value);
        determinePosition().then((value) {
          info = UploadInfo(
              candidates: candidates,
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

Future<Widget> getImageFromLibrary(LocationProvider locationProvider) async {
  List<String> candidates = [];
  String name = "";
  UploadInfo info;
  XFile? picked;
  Widget out_widget = const CircularProgressIndicator();
  File image = File("/assets/images/default.png");
  String hash = DateTime.now()
      .toString()
      .replaceAll(" ", "")
      .replaceAll(":", "")
      .replaceAll(".", "");
  if (await Permission.camera.request().isGranted &&
      await Permission.location.request().isGranted) {
    picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    try {
      // 画像をアップロード
      image = File(picked!.path);
      await uploadImage(image, hash);

      await sendVisionAI(hash)
          .then((value) => candidates = value["identities"]);
      locationProvider.updatePosition();
      log("実行された");
      info = UploadInfo(
          candidates: candidates,
          name: name,
          hash: hash,
          image: image,
          latitude: locationProvider.position.latitude,
          longitude: locationProvider.position.longitude,
          tags: []);
      out_widget = UploadForm(info);
    } catch (e) {
      delete_from_gcs(hash);
    }
  } else {
    return Error_Dialog("ライブラリ", "ライブラリの使用が許可されていません。");
  }

  return out_widget;
}

class UploadForm extends StatelessWidget {
  UploadInfo info;

  UploadForm(this.info);

  @override
  Widget build(BuildContext context) {
    final SearchProvider searchProvider = SearchProvider();
    return Scaffold(
        appBar: AppBar(title: Text("アップロード")),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: info.image == null
                    ? Text('No image selected.')
                    : Image.file(info.image),
              ),
              Row(
                children: [
                  Text("候補"),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: info.candidates.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(info.candidates[index]),
                          onTap: () {
                            info.name = info.candidates[index];
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Center(
                child: Row(
                  children: [
                    Text("植物名:"),
                    Flexible(
                      child: TextFormField(
                        initialValue: info.name,
                        onChanged: (text) {
                          info.name = text;
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: SearchGroup(
                    searchProvider: searchProvider,
                  )),
              OutlinedButton(
                  onPressed: (() {
                    // アップロード処理
                    final List<String> tag_name = [];
                    for (var i = 0; i < searchProvider.keep_tags.length; i++) {
                      tag_name.add(searchProvider.keep_tags[i]["name"]);
                    }
                    info.tags = tag_name;
                    showUploadingDialog(context, info);
                  }),
                  child: Text("アップロード")),
            ],
          ),
        ));
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
