import 'package:flutter/material.dart';
import 'dart:developer';

// 画像のパスのリスト(imagePaths)を渡すと垂直に並べて一覧で表示するWidget
class AssetPicturesListView extends StatelessWidget {
  AssetPicturesListView({Key? key, required this.imageDatas}) : super(key: key);
  final List imageDatas;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: imageDatas.length,
            itemBuilder: (context, index) {
              if (imageDatas[index].length == 2) {
                return PictureCard(
                    image: Image.asset(imageDatas[index][0]),
                    name: imageDatas[index][1],
                    detail: "");
              } else {
                return PictureCard(
                    image: Image.asset(imageDatas[index][0]),
                    name: imageDatas[index][1],
                    detail: imageDatas[index][2]);
              }
            }));
  }
}

// 画像のURLのリスト(imageUrls)を渡すと垂直に並べて一覧で表示するWidget
class NetworkPicturesListView extends StatelessWidget {
  NetworkPicturesListView({Key? key, required this.imageUrls})
      : super(key: key);
  final List imageUrls;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
      shrinkWrap: true,
      itemCount: imageUrls.length,
      itemBuilder: (BuildContext context, int index) {
        return PictureCard(
            image: Image.network(imageUrls[index]), name: "a", detail: "");
      },
    ));
  }
}

// 画像Widgetを渡すと良い感じに加工するWidget
// タップして詳細を表示などを実装したいときはここを変える
class PictureCard extends StatelessWidget {
  PictureCard(
      {Key? key, required this.image, required this.name, required this.detail})
      : super(key: key);
  final Widget image;
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Card(child: image),
        onTap: () {
          _showDialog(context, image, name, detail);
        });
  }
}

Future<void> _showDialog(
    BuildContext context, Widget image, String name, String detail) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              image,
              Text(detail),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('閉じる'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
