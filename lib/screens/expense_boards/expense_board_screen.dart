import 'dart:async';

import 'package:expensee/components/appbars/board_settings_app_bar.dart';
import 'package:expensee/components/appbars/individual_expense_board_app_bar.dart';
import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/components/expenses/expense.dart';
import 'package:expensee/components/nav_bars/board_nav_bar.dart';
import 'package:expensee/components/forms/create_expense_form.dart';
import 'package:expensee/components/nav_bars/board_settings_nav_bar.dart';
import 'package:expensee/components/nav_bars/expense_screen_nav_bar.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/main.dart';
import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/expense_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:expensee/screens/expense_boards/board_settings_screen.dart';
import 'package:expensee/screens/expense_boards/expense_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO - error handling, validation, styling
// TODO - restrict creation / display depending on user role
// TODO - navigation between settings options should take you back to settings screen, not expense view
class ExpenseBoardScreen extends StatefulWidget {
  static const routeName = "/expense-board";
  final String boardId;

  const ExpenseBoardScreen({super.key, required this.boardId});

  @override
  State<StatefulWidget> createState() => _ExpenseBoardScreenState();
}

class _ExpenseBoardScreenState extends State<ExpenseBoardScreen> {
  List<ExpenseItem> expenses = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool loading = false;
  final repo = ExpenseRepository();
  bool isGroupExpense = false;
  String boardName = "Expense Board";
  List<Widget> actionList = [];
  String memberRole =
      ""; // to let the nav bar render - re-assigned when data loaded in

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  onFinishEditing() => {
        setState(() => {displayBoard = true, editingExpense = null}),
        _refreshIndicatorKey.currentState?.show()
      };

  // No need to update refresh indicator state on exit, as not submitted.
  onExitExpenseView() => {setState(() => displayBoard = true)};

// Variables to help switching between creation and view of expenses
  bool displayBoard = true;
  Expense? editingExpense;

  // Variables to help switching between settings screen & board
  bool displaySettings = false;

  void _onOpenSettings() {
    if (mounted) {
      setState(() {
        displaySettings = true;
        displayBoard = false;
      });
    }
  }

  void _onExitSettings() {
    if (mounted) {
      setState(() {
        displayBoard = true;
        displaySettings = false;
      });
    }
  } //TODO

// Build out the list view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !displaySettings
          ? IndividualExpenseBoardAppBar(
              title: Text(
                boardName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: actionList,
            )
          : _buildAppBar(context),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _loadData,
          child: displayBoard
              ? _buildMainContent(context)
              : _buildAlternativeContent(context)),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    // Toggle normal view
    if (!displaySettings) {
      return BoardSettingsAppBar(context: context);
    }

    return BoardSettingsAppBar(
      context: context,
      onBack: _onExitSettings,
    );
  }

  Widget _buildNavBar(BuildContext context) {
    // Toggle board view
    if (!displaySettings && displayBoard) {
      return ExpenseBoardNavBar(
        boardId: widget.boardId,
        settings: _onOpenSettings,
        role: memberRole,
      );
    }
    // Toggle expense creation/modification view
    else if (!displaySettings && !displayBoard) {
      return ExpenseScreenNavBar(
          boardId: widget.boardId, exit: onExitExpenseView);
    }
    // Toggle settings view
    else {
      return ExpBoardSettingsNavBar(
          boardId: widget.boardId, exit: _onExitSettings);
    }
  }

  Widget _buildExpenseCreationScreen(BuildContext context) {
    return ExpenseCreationScreen(
      boardId: int.parse(widget.boardId),
      expense: editingExpense!,
      exists: editingExpense != null,
      onClose: () => onFinishEditing(),
    );
  }

// TODO - proper role handling
  Widget _buildAlternativeContent(BuildContext context) {
    if (!displaySettings) return _buildExpenseCreationScreen(context);
    return BoardSettingsScreen(
      id: widget.boardId,
      role: memberRole,
      boardId: widget.boardId,
      isGroup: isGroupExpense,
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        _renderProgressBar(context),
        Expanded(child: _renderListView(context)),
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: IconButton(
              icon: Image.asset(addImagePath,
                  fit: BoxFit.contain, width: 50, height: 50),
              onPressed: () => _navigateToCreationAndRefresh(),
            ))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

// renders loading bar view
  Widget _renderProgressBar(BuildContext context) {
    return (loading
        ? const CircularProgressIndicator(
            value: null,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          )
        : Container());
  }

// helper method
  Future<bool> _isPartOfGroup() async {
    bool isGroup = await Provider.of<ExpenseProvider>(context, listen: false)
        .isPartOfGroupBoard(widget.boardId);
    setState(() {
      isGroupExpense = isGroup;
    });
    return isGroupExpense;
  }

// renders list view of expenses
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
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              bool canEdit = await _canEditExpense(expenseItem.expense);
              if (!canEdit) {
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  builder: (BuildContext context) => DefaultAlertDialog(
                    title: "Permission Error",
                    errorMessage: deleteExpenseError,
                  ),
                );
                return false; // Prevent the dismiss if lacking perms
              } else {
                // Proceed with delete
                return true; // Allow the dismiss
              }
            }
            return false; // In case the direction doesn't match
          },
          onDismissed: (direction) {
            //TODO - ask for confirmation using dialog
            if (direction == DismissDirection.endToStart) {
              // make sure they have perms

              _deleteExpenseFromBoard(expenseItem.expense, context);
            }
          },
          direction: DismissDirection.endToStart,
          child: GestureDetector(
              onTap: () {
                // Check if creator OR admin/owner
                _navigateToEditAndRefresh(expenseItem.expense, context);
              },
              child: _renderExpenseView(expenseItem.expense)),
        ),
      ],
    );
  }

// Checks if user can edit an expense - used when tapping on expense.
  Future<bool> _canEditExpense(Expense e) async {
    if (e.creatorId == supabase.auth.currentUser!.id) {
      return true;
    } else if (await Provider.of<BoardProvider>(context, listen: false)
        .checkIfAdmin(widget.boardId)) {
      return true;
    } else if (await Provider.of<BoardProvider>(context, listen: false)
        .checkIfOwner(widget.boardId)) {
      return true;
    }

    return false;
  }

// TODO - Styling + constants file
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "£${expense.amount.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Future<bool> _deleteExpenseFromBoard(
      Expense expense, BuildContext context) async {
    Expense? del = await Provider.of<ExpenseProvider>(context, listen: false)
        .removeExpense(expense.id!);
    if (del != null) {
      // Remove from board database table then, expense list, then refresh
      expenses.removeWhere((element) => element.expense.id == expense.id);
      await _refreshExpenses();
      return true;
    }
    return false;
  }

  Future<void> _fetchMemberRole() async {
    if (!mounted) return;
    memberRole = await Provider.of<GroupMemberProvider>(context, listen: false)
        .getMemberRole(widget.boardId);
  }

  Future<void> _fetchExpenses() async {
    if (!mounted) {
      return; // If widget isn't in tree, stop to prevent crash
    }

    // get board, then from board get its expense list using provider.
    final board = await Provider.of<BoardProvider>(context, listen: false)
        .fetchBoardExpenses(widget.boardId);

// TODO - handle expenses being empty - render a message, or an empty icon?
    if (board != null) {
      if (board.expenses.isNotEmpty) {
        setState(() {
          expenses = board.expenses
              .map((rawExpense) => CreateExpenseForm(
                    expense: rawExpense,
                    exists: true,
                    onClose: () => onFinishEditing(),
                  ))
              .toList();
        });
      }
    }
  }

  Future<void> _refreshExpenses() async {
    await _fetchExpenses();
    await _getAppbarActions(widget.boardId);
    _refreshIndicatorKey.currentState?.show();
  }

// Handle loading in the expenses
  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
      await _fetchMemberRole();
      await _fetchExpenses();
      await _isPartOfGroup();
      await _getBoardName(widget.boardId);
      await _getAppbarActions(widget.boardId);
      // await _updateExpenseBalances(widget.boardId);
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

// Switches rendered widget to creation form, but on an existing expense
  Future<void> _navigateToEditAndRefresh(Expense expense, context) async {
    if (!await _canEditExpense(expense)) {
      showDialog(
          context: context,
          builder: (BuildContext context) => DefaultAlertDialog(
                title: "Permission Error",
                errorMessage: modifyExpenseError,
              ));
      return;
    }

    if (mounted) {
      setState(() {
        editingExpense = expense;
        displayBoard = false;
      });
      await _refreshExpenses();
    }
  }

// Switches rendered widget to creation form widget
  Future<void> _navigateToCreationAndRefresh() async {
    var expense = await _generateBlankExpense();
    if (mounted) {
      setState(() {
        editingExpense = expense;
        displayBoard = false;
      });
      await _refreshExpenses();
    } else {
      await _deleteExpenseFromBoard(expense, context);
    }
  }

  Future<void> _getBoardName(boardId) async {
    boardName = await Provider.of<BoardProvider>(context, listen: false)
        .getBoardName(boardId);
  }

  Future<void> _getAppbarActions(boardId) async {
    var boardBalance = await Provider.of<BoardProvider>(context, listen: false)
        .getBoardBalance(boardId);
    actionList = [
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Text("£$boardBalance"),
      )
    ];
  }
}
