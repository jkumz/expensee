import 'package:expensee/components/nav_bars/default_bottom_bar.dart';
import 'package:expensee/components/forms/create_expense_board_form.dart';
import 'package:flutter/material.dart';

class BoardCreationScreen extends StatefulWidget {
  static const routeName = "/create-board";

  const BoardCreationScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BoardCreationScreenState();
}

class _BoardCreationScreenState extends State<BoardCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateExpenseBoardForm(),
      bottomNavigationBar: const DefaultBottomAppBar(),
    );
  }
}
