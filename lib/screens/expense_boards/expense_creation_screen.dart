import 'package:expensee/components/appbars/create_expense_app_bar.dart';
import 'package:expensee/components/bottom_bars/default_bottom_bar.dart';
import 'package:expensee/components/forms/create_expense_form.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:flutter/material.dart';

class ExpenseCreationScreen extends StatefulWidget {
  static const routeName = "/create-expense";

  final Expense expense;

  const ExpenseCreationScreen({super.key, required this.expense});

  @override
  createState() => _ExpenseCreationScreenState();
}

class _ExpenseCreationScreenState extends State<ExpenseCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateExpenseAppBar(),
      body: CreateExpenseForm(expense: widget.expense),
      bottomNavigationBar: const DefaultBottomAppBar(),
    );
  }
}
