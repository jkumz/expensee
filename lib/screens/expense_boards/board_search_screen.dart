import 'package:expensee/components/forms/search_form.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:flutter/material.dart';

class BoardSearchScreen extends StatefulWidget {
  static const routeName = "/board-settings";
  final String boardId;
  final bool isGroup;
  final Function(ExpenseBoard) onApplyFilter;

  const BoardSearchScreen(
      {Key? key,
      required this.boardId,
      required this.isGroup,
      required this.onApplyFilter});

  @override
  createState() => _BoardSearchScreenState();
}

class _BoardSearchScreenState extends State<BoardSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchForm(
        boardId: widget.boardId,
        onApplyFilter: widget.onApplyFilter,
      ),
    );
  }
}
