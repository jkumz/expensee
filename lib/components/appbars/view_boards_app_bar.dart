import "package:flutter/material.dart";

// For readability
class ViewBoardsAppBar extends AppBar {
  ViewBoardsAppBar({
    Key? key,
    Widget title = const Text("View Expense Boards"),
    List<Widget>? actions,
  }) : super(
            key: key,
            title: title,
            actions: actions,
            leading: null,
            automaticallyImplyLeading: false);
}
