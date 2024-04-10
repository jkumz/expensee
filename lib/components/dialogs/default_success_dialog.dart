import 'package:flutter/material.dart';

class DefaultSuccessDialog extends StatelessWidget {
  final String successMessage;
  String title;

  DefaultSuccessDialog({
    Key? key,
    this.title = "Success",
    required this.successMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: TextStyle(color: Colors.white)),
      backgroundColor: Color.fromARGB(255, 71, 109, 72),
      content: Text(
        successMessage,
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
