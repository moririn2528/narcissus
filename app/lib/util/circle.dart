import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

void showWaitingDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false, // ユーザーがダイアログ外をタップして閉じないようにする
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(), // サークルを表示
            SizedBox(width: 20.0),
            Text('処理中...'), // テキストメッセージを表示
          ],
        ),
      );
    },
  );
}
