import 'package:expensee/components/buttons/custom_callback_img_button.dart';
import 'package:expensee/config/constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MassEmailButton extends ImageCallbackButton {
  MassEmailButton({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    String imagePath = massEmailImagePath,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          isEnabled: isEnabled,
          imagePath: imagePath,
        );
}
