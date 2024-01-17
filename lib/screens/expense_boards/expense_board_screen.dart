import 'dart:async';
import 'dart:math';

import 'package:expensee/app.dart';
import 'package:expensee/components/appbars/individual_expense_board_app_bar.dart';
import 'package:expensee/components/bottom_bars/board_settings_nav_bar.dart';
import 'package:expensee/components/expenses/base_expense.dart';
import 'package:expensee/components/forms/create_expense_form.dart';
import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/expense_provider.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/expense_boards/expense_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

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
  List<BaseExpenseItem> expenses = [];
  bool loading = false;
  final repo = ExpenseRepository();
  bool isGroupExpense = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
            Expanded(child: _renderListView(context)),
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Image.asset("assets/images/add.png",
                      fit: BoxFit.contain, width: 50, height: 50),
                  onPressed: () => _navigateToCreationAndRefresh(),
                ))
          ],
        ),
      ),
      bottomNavigationBar: ExpenseBoardNavBar(boardId: widget.boardId),
    );
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<bool> _isPartOfGroup() async {
    bool isGroup = await repo.isPartOfGroup(widget.boardId);
    setState(() {
      isGroupExpense = isGroup;
    });
    return isGroupExpense;
  }

  Widget _renderListView(BuildContext context) {
    return ListView.builder(
        itemCount: expenses.length, itemBuilder: _listViewItemBuilder);
  }

// used to build out each expense item in the list view, based on their index
  Widget _listViewItemBuilder(BuildContext context, int index) {
    final expenseItem = expenses[index];

    return Column(
      children: [
        Dismissible(
          key: Key(expenseItem.expense.id.toString()),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              _deleteExpenseFromBoard(expenseItem.expense, context);
            }
          },
          direction: DismissDirection.endToStart,
          child: GestureDetector(
              onTap: () {
                _navigateToEditAndRefresh(expenseItem.expense, context);
              },
              child: _renderExpenseView(expenseItem.expense)),
        ),
      ],
    );
  }

  Widget _renderExpenseView(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // Left column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expenseDateToString(expense.date),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "£${expense.amount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          _renderVerticalDivider(),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(expense.category,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Text(
                expense.description ?? "",
                style: const TextStyle(fontSize: 16),
              )
            ],
          )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Balance: £${expense.balance.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14),
              )
            ],
          )
        ]),
      ),
    );
  }

//TODO - make the dividers visible... a black line will do
  Widget _renderVerticalDivider() {
    return const VerticalDivider(
      width: 2,
      thickness: 1,
      color: Colors.black,
    );
  }

  // used to build out each expense item in the list view, based on their index
  Widget _listViewEditableItemBuilder(BuildContext context, int index) {
    BaseExpenseItem expenseItem = expenses[index];

    return Column(
      children: [
        Dismissible(
          key: Key(expenseItem.expense.id.toString()),
          child: CreateExpenseForm(expense: expenseItem.expense),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              _deleteExpenseFromBoard(expenseItem.expense, context);
            }
          },
        ),
      ],
    );
  }

  Future<bool> _deleteExpenseFromBoard(
      Expense expense, BuildContext context) async {
    // try {
    Expense? deleted = await repo.removeExpense(expense.id!);
    if (deleted != null) {
      // Remove from board database table then, expense list, then refresh
      expenses.removeWhere((element) => element.expense.id == expense.id);
      _refreshExpenses();
      return true;
    }
    return false;
  }

  Future<void> _fetchExpenses() async {
    if (!mounted) {
      return; // If widget isn't in tree, stop to prevent crash
    }

    // get board, then from board get its expense list using provider.
    final board = await Provider.of<BoardProvider>(context, listen: false)
        .fetchBoardExpenses(widget.boardId);

    if (board != null) {
      if (board.expenses.isNotEmpty) {
        setState(() {
          expenses = board.expenses
              .map((rawExpense) => CreateExpenseForm(expense: rawExpense))
              .toList();
        });
      }
    }
  }

  Future<void> _refreshExpenses() async {
    await _fetchExpenses();
  }

// Handle loading in the expenses
  Future<void> _loadData() async {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
      await _fetchExpenses();
      await _isPartOfGroup();
      setState(() {
        loading = false;
      });
    }
  }

// Handle adding new expenses
  Future<Expense> _generateBlankExpense() async {
    var expense = Expense.blank();
    var json = expense.toJson();
    json["board_id"] = widget.boardId;
    expense = await Provider.of<ExpenseProvider>(context, listen: false)
        .addExpense(json);
    _refreshExpenses();
    return expense;
  }

  Future<void> _navigateToEditAndRefresh(Expense expense, context) async {
    if (mounted) {
      await Navigator.pushNamed(context, ExpenseCreationScreen.routeName,
          arguments: ExpenseCreationSreenArguments(expense: expense));

      await _refreshExpenses();
    }
  }

  Future<void> _navigateToCreationAndRefresh() async {
    // Navigate and wait for result
    var expense = await _generateBlankExpense();
    if (mounted) {
      await Navigator.pushNamed(context, ExpenseCreationScreen.routeName,
          arguments: ExpenseCreationSreenArguments(expense: expense));

      await _refreshExpenses();
    } else {
      await _deleteExpenseFromBoard(expense, context);
    }
  }
}
