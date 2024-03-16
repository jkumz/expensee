// purely for readability
import 'package:flutter/material.dart';

class AcceptInviteButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;

  const AcceptInviteButton(
      {super.key,
      required this.text,
      required this.imagePath,
      required this.onPressed});

// TODO - text styling
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: Image.asset(imagePath, width: 40, height: 42));
  }
}
