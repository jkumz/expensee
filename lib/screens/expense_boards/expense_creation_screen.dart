import 'package:expensee/components/forms/create_expense_form.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:flutter/material.dart';

class ExpenseCreationScreen extends StatefulWidget {
  static const routeName = "/create-expense";

  final Expense expense;
  final int boardId;
  final bool exists;
  final VoidCallback onClose;

  const ExpenseCreationScreen(
      {super.key,
      required this.expense,
      required this.boardId,
      required this.exists,
      required this.onClose});

  @override
  createState() => _ExpenseCreationScreenState();
}

class _ExpenseCreationScreenState extends State<ExpenseCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateExpenseForm(
        expense: widget.expense,
        exists: widget.exists,
        onClose: widget.onClose,
      ),
    );
  }
}
