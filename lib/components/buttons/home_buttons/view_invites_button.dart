import 'package:flutter/material.dart';

class ViewInvitesButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;

  const ViewInvitesButton(
      {super.key,
      required this.text,
      required this.imagePath,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(imagePath, width: 24, height: 24), // Use imagePath here
      label: Text(text), // Text on the right
      onPressed: onPressed,
    );
  }
}
