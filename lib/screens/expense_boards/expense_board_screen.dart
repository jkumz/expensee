import 'dart:async';

import 'package:expensee/components/appbars/individual_expense_board_app_bar.dart';
import 'package:expensee/components/bottom_bars/board_settings_nav_bar.dart';
import 'package:expensee/components/bottom_bars/default_bottom_bar.dart';
import 'package:expensee/components/expenses/expense.dart';
import 'package:expensee/components/forms/create_expense_board_form.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/mocks/mock_expense.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// TODO - error handling, validation, styling
// TODO - restrict creation / display depending on user role
class ExpenseBoardScreen extends StatefulWidget {
  static const routeName = "/expense-board";
  final String boardId;

  const ExpenseBoardScreen({required this.boardId});

  @override
  State<StatefulWidget> createState() => _ExpenseBoardScreenState();
}

class _ExpenseBoardScreenState extends State<ExpenseBoardScreen> {
  List<ExpenseItem> expenses = [];
  bool loading = false;
  final repo = ExpenseRepository();

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

// Build out the list view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndividualExpenseBoardAppBar(
        actions: [/*TODO*/],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            _renderProgressBar(context),
            Expanded(child: _renderListView(context))
          ],
        ),
      ),
      bottomNavigationBar: ExpenseBoardNavBar(boardId: widget.boardId),
    );
  }

// renders loading bar view
  Widget _renderProgressBar(BuildContext context) {
    return (this.loading
        ? const CircularProgressIndicator(
            value: null,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          )
        : Container());
  }

  Widget _renderListView(BuildContext context) {
    if (expenses?.isEmpty == true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(noExpensesText),
          ),
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon: Image.asset(addBoardImagePath,
                    fit: BoxFit.contain, width: 50, height: 50),
                onPressed: () => _navigateToCreationAndRefresh(),
              ))
        ],
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: _listViewItemBuilder,
    );
  }

// used to build out each expense item in the list view, based on their index
  Widget _listViewItemBuilder(BuildContext context, int index) {
    final expenseItem = expenses[index];

    return Column(
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(expenseItem.expense.category),
            subtitle: Text(expenseItem.expense.description ?? ""),
            leading: Text(expenseItem.expense.date.toString()),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('£${expenseItem.expense.amount.toStringAsFixed(2)}'),
                SizedBox(height: 4),
                Text(
                    'Balance: £${expenseItem.expense.balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: IconButton(
              icon: Image.asset("assets/images/add.png",
                  fit: BoxFit.contain, width: 50, height: 50),
              onPressed: () => _navigateToCreationAndRefresh(),
            ))
      ],
    );
  }

  Future<void> _fetchExpenses() async {
    var rawExpenses = await repo.refreshExpenses(widget.boardId);
    setState(() {
      expenses =
          rawExpenses.map((expense) => ExpenseItem(expense: expense)).toList();
    });
  }

  Future<void> _refreshExpenses() async {
    setState(() {
      // BLANK - Simply to refresh.
    });
  }

// Handle loading in the expenses
  Future<void> _loadData() async {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
      setState(() async {
        await _fetchExpenses();
        loading = false;
      });
    }
  }

// Handle adding new expenses
  Future<void> _addExpense(Expense expense) async {
    Navigator.pushNamed(context, BoardCreationScreen.routeName);
  }

  Future<bool> _removeExpense(Expense expense) async {
    final removed = await repo.removeExpense("${expense.id}");

    return removed;
  }

  Future<void> _navigateToCreationAndRefresh() async {
    // Navigate and wait for result
    await Navigator.of(context).pushNamed(BoardCreationScreen.routeName);

    await _refreshExpenses();
  }
}
