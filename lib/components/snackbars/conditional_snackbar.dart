import 'package:flutter/material.dart';

class ConditionalSnackbar extends SnackBar {
  late String? message, errMsg;
  late bool success;

  ConditionalSnackbar(
      {required super.content,
      String? message,
      String? errMsg,
      required bool success});

  static void show(BuildContext context,
      {bool isSuccess = true, String? message, String? errMsg}) {
    final fullMessage = isSuccess ? message : errMsg;

    final snackBar = SnackBar(
      content: Text(fullMessage!),
      backgroundColor:
          isSuccess ? Colors.green : Theme.of(context).colorScheme.error,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
