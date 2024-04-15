import "package:flutter/material.dart";

// For readability
class BoardSettingsAppBar extends AppBar {
  BoardSettingsAppBar(
      {Key? key,
      Widget title = const Center(child: Text("Board Settings")),
      List<Widget>? actions,
      required BuildContext context,
      VoidCallback? onBack})
      : super(
            key: key,
            title: title,
            actions: actions,
            leading: null,
            automaticallyImplyLeading: false);
}
