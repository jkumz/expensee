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
      title: Text(title,
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      content: Text(errorMessage,
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      backgroundColor: const Color.fromARGB(255, 189, 29, 17),
      actions: <Widget>[
        TextButton(
          child: const Text('OK',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
