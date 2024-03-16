// purely for readability
import 'package:flutter/material.dart';

class DeclineInviteButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;

  const DeclineInviteButton(
      {super.key,
      required this.text,
      required this.imagePath,
      required this.onPressed});

// TODO - text styling
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: Image.asset(imagePath, width: 40, height: 50));
  }
}
