import 'package:expensee/styles.dart';
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
      style: standardMenuOptionStyle,
      child: child,
    );
  }
}
