import 'dart:math';

import 'package:expensee/components/expenses/expense.dart';
import 'package:expensee/models/expense_model.dart';

mixin MockExpense implements ExpenseItem {
  static final List<ExpenseItem> expenses = [
    ExpenseItem(
        expense: Expense(
            date: '30/12/2023',
            category: 'Living',
            amount: 1.39,
            balance: 4.19)),
    ExpenseItem(
        expense: Expense(
            date: '29/12/2023',
            category: 'Pets',
            amount: 13.19,
            balance: 17.38)),
    ExpenseItem(
        expense: Expense(
            date: '29/12/2023', category: 'Car', amount: 1.39, balance: 4.19)),
    ExpenseItem(
        expense: Expense(
            date: '29/12/2023',
            category: 'Living',
            amount: 1.39,
            balance: 4.19)),
    ExpenseItem(
        expense: Expense(
            date: '28/12/2023', category: 'Work', amount: 1.39, balance: 4.19)),
  ];

  static getAllExpenses() => expenses;

  static getExpense(int index) => expenses[index];
}
