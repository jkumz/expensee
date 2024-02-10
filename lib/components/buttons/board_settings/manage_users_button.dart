import 'package:expensee/config/constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ManageRolesButton extends StatelessWidget {
  final String text;
  late String imagePath = manageUsersImagePath;
  final VoidCallback onPressed;

  ManageRolesButton({super.key, required this.text, required this.onPressed});

// TODO - text styling
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        icon: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Image.asset(imagePath, width: 80, height: 80),
        ), // Image on the left
        label: Text(text), // Text on the right
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            alignment: Alignment.centerLeft,
            textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
  }
}
