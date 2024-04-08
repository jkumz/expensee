import 'package:flutter/material.dart';

class ConfirmationAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmationAlertDialog(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(false); // Return false when "No" is pressed
          },
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(true); // Return true when "Yes" is pressed
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
