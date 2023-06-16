import 'package:flutter/material.dart';
import '../util/picturesListView.dart';
import '../local_plant/plants.dart';

class ResultPage extends StatefulWidget {
  final Plants imageUrls;
  ResultPage({required this.imageUrls});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索結果'),
      ),
      body: Center(child: NetworkPicturesListView(imageUrls: widget.imageUrls)),
    );
  }
}
