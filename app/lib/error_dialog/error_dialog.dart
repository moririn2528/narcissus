import 'package:flutter/material.dart';

void showError_Dialog(context, String title, String content) {
  showDialog(
      context: context,
      builder: ((context) =>
          SimpleDialog(title: Text(title), children: <Widget>[Text(content)])));
}

Widget Error_Dialog(String title, String content) {
  return SimpleDialog(title: Text(title), children: <Widget>[Text(content)]);
}
