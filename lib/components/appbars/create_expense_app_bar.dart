import "package:flutter/material.dart";

// For readability
class CreateExpenseAppBar extends AppBar {
  CreateExpenseAppBar({
    Key? key,
    Widget title = const Text("Create Expense"),
    List<Widget>? actions,
  }) : super(
            key: key,
            title: title,
            actions: actions,
            leading: null,
            automaticallyImplyLeading: false);
}
