import "package:flutter/material.dart";

// For readability
class IndividualExpenseBoardAppBar extends AppBar {
  IndividualExpenseBoardAppBar({
    Key? key,
    Widget title = const Text("Expense Board"),
    List<Widget>? actions,
  }) : super(key: key, title: title, actions: actions);
}
