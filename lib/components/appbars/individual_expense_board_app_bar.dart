import "package:flutter/material.dart";

// For readability
class IndividualExpenseBoardAppBar extends AppBar {
  IndividualExpenseBoardAppBar({
    Key? key,
    required Widget title,
    List<Widget>? actions,
  }) : super(key: key, title: title, actions: actions);
}
