import 'dart:math';

import 'package:expensee/components/expenses/expense.dart';
import 'package:expensee/models/expense_model.dart';

mixin MockExpense implements ExpenseItem {
  static final List<ExpenseItem> expenses = [
    ExpenseItem(
        expense: Expense(
            date: DateTime.now(),
            category: 'Living',
            amount: 1.39,
            balance: 4.19)),
    ExpenseItem(
        expense: Expense(
            date: DateTime.now(),
            category: 'Pets',
            amount: 13.19,
            balance: 17.38)),
    ExpenseItem(
        expense: Expense(
            date: DateTime.now(),
            category: 'Car',
            amount: 1.39,
            balance: 4.19)),
    ExpenseItem(
        expense: Expense(
            date: DateTime.now(),
            category: 'Living',
            amount: 1.39,
            balance: 4.19)),
    ExpenseItem(
        expense: Expense(
            date: DateTime.now(),
            category: 'Work',
            amount: 1.39,
            balance: 4.19)),
  ];

  static getAllExpenses() => expenses;

  static getExpense(int index) => expenses[index];
}
