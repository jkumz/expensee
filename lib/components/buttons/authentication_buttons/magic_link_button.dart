import 'package:flutter/material.dart';

class MagicLinkButton extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final Color? textColour;
  final Color? backgroundColour;

  const MagicLinkButton(this.child, this.onTap,
      {super.key, this.textColour, this.backgroundColour});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap != null
          ? () {
              onTap!();
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
