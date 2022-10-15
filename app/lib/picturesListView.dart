import 'package:flutter/material.dart';
import 'dart:developer';

// 画像のパスのリスト(imagePaths)を渡すと垂直に並べて一覧で表示するWidget
class AssetPicturesListView extends StatelessWidget{
  AssetPicturesListView({Key? key, required this.imagePaths}) : super(key: key);
  final List imagePaths;

  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: imagePaths.length,
      itemBuilder: (BuildContext context, int index) {
        return PictureCard(image: Image.asset(imagePaths[index]));
      },
    );
  }
}

// 画像のURLのリスト(imageUrls)を渡すと垂直に並べて一覧で表示するWidget
class NetworkPicturesListView extends StatelessWidget{
  NetworkPicturesListView({Key? key, required this.imageUrls}) : super(key: key);
  final List imageUrls;

  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (BuildContext context, int index) {
        return PictureCard(image: Image.network(imageUrls[index]));
      },
    );
  }
}

// 画像Widgetを渡すと良い感じに加工するWidget
// タップして詳細を表示などを実装したいときはここを変える
class PictureCard extends StatelessWidget{
  PictureCard({Key? key, required this.image}) : super(key: key);
  final Widget image;

  @override
  Widget build(BuildContext context){
    return Card(child: image);
  }
}