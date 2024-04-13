import 'package:expensee/styles.dart';
import 'package:flutter/material.dart';

class ViewExpenseBoardsButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;

  const ViewExpenseBoardsButton(
      {super.key,
      required this.text,
      required this.imagePath,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(imagePath, width: 80, height: 80), // Use imagePath here
      label: Text(text), // Text on the right
      onPressed: onPressed,
      style: standardMenuOptionStyleWithIcon,
    );
  }
}
