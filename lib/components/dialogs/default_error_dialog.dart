import 'package:flutter/material.dart';

class DefaultErrorDialog extends StatelessWidget {
  final String errorMessage;
  String title;

  DefaultErrorDialog({
    Key? key,
    this.title = "Error",
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(errorMessage),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
