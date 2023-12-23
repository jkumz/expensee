import 'package:expensee/components/appbars/view_boards_app_bar.dart';
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: getAllSoloExpenseBoards(),
      ),
    );
  }

// TODO - Connect to API, pull and process!
  List<Widget> getAllSoloExpenseBoards() {
    return new List.empty();
  }
}
