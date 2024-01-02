import 'dart:async';
import 'dart:math';

import 'package:expensee/components/appbars/individual_expense_board_app_bar.dart';
import 'package:expensee/components/expenses/expense.dart';
import 'package:expensee/mocks/mock_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpenseList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<ExpenseItem> expenses = MockExpense.getAllExpenses();
  bool loading = false;

// Build out the list view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndividualExpenseBoardAppBar(
        actions: [/*TODO*/],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: Column(
          children: [
            renderProgressBar(context),
            Expanded(child: renderListView(context))
          ],
        ),
      ),
    );
  }

// renders loading bar view
  Widget renderProgressBar(BuildContext context) {
    return (this.loading
        ? const LinearProgressIndicator(
            value: null,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          )
        : Container());
  }

  Widget renderListView(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: _listViewItemBuilder,
    );
  }

// used to build out each expense item in the list view, based on their index
  Widget _listViewItemBuilder(BuildContext context, int index) {
    final expenseItem = expenses[index];

    return Card(
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
            Text('Balance: £${expenseItem.expense.balance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

// Handle loading in the expenses
  Future<void> loadData() async {
    if (this.mounted) {
      setState(() => this.loading = true);
      // to simulate waiting - testing only - REMOVE LATER!
      Timer(Duration(milliseconds: 3000), () async {
        final expenses = await MockExpense.getAllExpenses();
        setState(() {
          this.expenses = expenses;
          this.loading = false;
        });
      });
    }
  }
}
