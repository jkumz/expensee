import 'package:expensee/components/appbars/view_boards_app_bar.dart';
import 'package:flutter/material.dart';

class ViewExpenseBoardsGroups extends StatefulWidget {
  static const routeName = "/group-expense-boards";

  const ViewExpenseBoardsGroups({super.key});

  @override
  State<StatefulWidget> createState() => _ViewExpenseBoardsGroupsState();
}

class _ViewExpenseBoardsGroupsState extends State<ViewExpenseBoardsGroups> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ViewBoardsAppBar(
        title: const Text("View Group Expense Boards"),
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
