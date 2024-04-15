import "package:flutter/material.dart";

// For readability
class HomeAppBar extends AppBar {
  HomeAppBar({
    Key? key,
    Widget title = const Center(child: Text("Home")),
    List<Widget>? actions,
  }) : super(
            key: key,
            title: title,
            actions: actions,
            leading: null,
            automaticallyImplyLeading: false);
}
