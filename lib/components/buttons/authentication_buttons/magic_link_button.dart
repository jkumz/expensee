import 'package:expensee/styles.dart';
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
      style: standardMenuOptionStyle,
      child: child,
    );
  }
}
