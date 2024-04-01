import 'package:expensee/components/buttons/custom_callback_img_button.dart';
import 'package:flutter/material.dart';
import 'package:expensee/config/constants.dart';

class PassOwnershipButton extends ImageCallbackButton {
  PassOwnershipButton({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    String imagePath = transferImagePath,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          isEnabled: isEnabled,
          imagePath: imagePath,
        );
}
