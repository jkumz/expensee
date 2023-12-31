import 'package:expensee/components/appbars/view_boards_app_bar.dart';
import 'package:expensee/components/elevated_buttons/custom_callback_button.dart';
import 'package:expensee/components/lists/expense_list.dart';
import 'package:expensee/screens/home.dart';
import 'package:flutter/material.dart';

class ViewExpenseBoardsSolo extends StatefulWidget {
  static const routeName = "/solo-expense-boards";

  const ViewExpenseBoardsSolo({super.key});

  @override
  State<StatefulWidget> createState() => _ViewExpenseBoardsSoloState();
}

class _ViewExpenseBoardsSoloState extends State<ViewExpenseBoardsSolo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ViewBoardsAppBar(
        actions: [
          //TODO - Add expense board button
        ],
      ),
      body: getAllSoloExpenseBoards(),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 3.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomCallbackButton(Text("Back"), () {
              Navigator.of(context).pushReplacementNamed(Home.routeName);
            })
          ], //TODO - Make this an icon button
        ),
      ),
    );
  }

// TODO - Connect to API, pull and process!
  getAllSoloExpenseBoards() {
    return ExpenseList();
  }
}
