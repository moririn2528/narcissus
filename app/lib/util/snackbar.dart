import 'package:flutter/material.dart';

SnackBar redsnackbar(String text) {
  return SnackBar(
    content: Text(
      text,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
    closeIconColor: Colors.white,
  );
}

SnackBar greensnackbar(String text) {
  return SnackBar(
    content: Text(
      text,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
    closeIconColor: Colors.white,
  );
}
