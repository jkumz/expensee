import 'package:flutter/material.dart';

class ImageCallbackButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;
  bool isEnabled;
  final double? width, height;
  final AlignmentGeometry? contentAlignment;

  ImageCallbackButton(
      {Key? key,
      required this.text,
      required this.onPressed,
      required this.imagePath,
      this.isEnabled = true,
      this.width,
      this.height,
      this.contentAlignment = Alignment.centerLeft})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Image.asset(imagePath, width: width ?? 80, height: height ?? 80),
      ),
      label: Text(text),
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        alignment: contentAlignment ?? Alignment.centerLeft,
        textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}
