import 'package:flutter/material.dart';

class CustomCallbackButton extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final Color? textColour;
  final Color? backgroundColour;

  const CustomCallbackButton(this.child, this.onTap,
      {super.key, this.textColour, this.backgroundColour});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap != null
          ? () {
              onTap!(); // ! operator basically says its guaranteed to not be null
            }
          : null,
      style: ElevatedButton.styleFrom(
          foregroundColor: (textColour ?? Colors.white),
          backgroundColor:
              (backgroundColour ?? const Color.fromARGB(255, 170, 76, 175)),
          elevation: 1,
          textStyle: const TextStyle(/*TODO make custom text styles*/)),
      child: child,
    );
  }
}
