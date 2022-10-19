import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ウィジェット間でデータを共有するためのクラス
class SearchProvider with ChangeNotifier {
  List? suggested_tags = [];
  List? fetched_tags = [];
  List? keep_tags = [];
  TextEditingController fieldController = new TextEditingController(text: '');

  SearchProvider() {
    fetchtags().then(((value) => null), onError: (error) => print(error));
  }

  Future<List> fetchtags() async {
    final response =
        await http.get(Uri.parse('http://${dotenv.get('API_IP')}/api/tag'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      fetched_tags = [];
      for (var v in data) {
        fetched_tags!.add(v["name"]);
      }
      notifyListeners();
      return data;
    } else {
      throw Exception('Failed to load tags');
    }
  }

// タグの提案があるかどうかを判定する
  isopened() {
    if (suggested_tags!.isEmpty) {
      return 0;
    }
    return 1;
  }

// 提案するタグを更新する
  suggestion() {
    if (fieldController.text.isNotEmpty) {
      suggested_tags = fetched_tags!
          .where((tag) => tag.toString().contains(fieldController.text))
          .toList();
      notifyListeners();
    } else {
      suggested_tags = [];
      notifyListeners();
    }
  }

// 選ばれたタグを保持する
  addtag(String tag) {
    keep_tags!.add(tag);
    notifyListeners();
  }

// 選ばれたタグを保持から外す
  removetag(String tag) {
    keep_tags!.remove(tag);
    notifyListeners();
  }
}
