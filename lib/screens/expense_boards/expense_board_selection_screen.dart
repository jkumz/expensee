// ignore_for_file: use_build_context_synchronously

import 'package:expensee/components/appbars/view_boards_app_bar.dart';
import 'package:expensee/components/dialogs/confirmation_dialog.dart';
import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/components/dialogs/default_success_dialog.dart';
import 'package:expensee/components/nav_bars/default_bottom_bar.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/expense_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/expense_boards/expense_board_screen.dart';
import 'package:flutter/material.dart';
import "package:expensee/models/expense_board/expense_board.dart";
import 'package:provider/provider.dart';

class SelectExpenseBoardsScreen extends StatefulWidget {
  static const routeName = "/expense-boards";
  final bool isGroupBoardScreen;

  const SelectExpenseBoardsScreen(
      {super.key, required this.isGroupBoardScreen});

  @override
  State<StatefulWidget> createState() => _SelectExpenseBoardsScreenState();
}

class _SelectExpenseBoardsScreenState extends State<SelectExpenseBoardsScreen> {
  late List<ExpenseBoard> boards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh boards when this screen is displayed
      Provider.of<BoardProvider>(context, listen: false)
          .refreshBoards(widget.isGroupBoardScreen);
    });
  }

// Helper method for updating state
  void _fetchBoards() async {
    var temp = await Provider.of<BoardProvider>(context, listen: false)
        .refreshBoards(widget.isGroupBoardScreen);
    if (mounted) {
      setState(() {
        if (temp != null) boards = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ViewBoardsAppBar(
          actions: [
            //TODO - Add expense board button
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<BoardProvider>(
              builder: (context, boardProvider, _) {
                if (boardProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                boards = boardProvider.boards;
                return _buildBoardListView(boards, context, boardProvider);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon: Image.asset(addImagePath,
                    fit: BoxFit.contain, width: 50, height: 50),
                onPressed: () => _navigateToCreationAndRefresh(),
              ),
            )
          ],
        ),
        bottomNavigationBar: const DefaultBottomAppBar());
  }

  void _navigateToExpenseBoard(BuildContext context, String boardId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ExpenseProvider(boardId),
          child: ExpenseBoardScreen(boardId: boardId),
        ),
      ),
    ).then((_) => _fetchBoards());
  }

  Widget _buildBoardItem(ExpenseBoard board, BuildContext context) {
    return Dismissible(
      key: Key(board.id.toString()),
      background: Container(color: Colors.red),
      child: ListTile(
        title: Center(child: Text(board.name)),
        onTap: () => _navigateToExpenseBoard(context, board.id.toString()),
      ),
      confirmDismiss: (direction) {
        return _promptLeavingBoard(board.id!.toString());
      },
      onDismissed: (direction) => {
        if (direction == DismissDirection.endToStart)
          {
            _leaveExpenseBoard(board.id!.toString()).then((hasLeft) {
              if (hasLeft) {
                if (mounted) {
                  setState(() {
                    boards.removeWhere((element) => element.id! == board.id!);
                  });
                }
              }
            })
          }
      },
    );
  }

  Widget _buildBoardListView(List<ExpenseBoard> boards, BuildContext context,
      BoardProvider boardProvider) {
    return boards.isEmpty
        ? const Center(
            child: Column(
            children: [
              Text(noBoards),
            ],
          ))
        : Expanded(
            child: ListView.builder(
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                return _buildBoardItem(board, context);
              },
            ),
          );
  }

  Future<void> _navigateToCreationAndRefresh() async {
    // Navigate and wait for result
    await Navigator.of(context).pushNamed(BoardCreationScreen.routeName);

    _fetchBoards();
  }

  Future<bool> _leaveExpenseBoard(String boardId) async {
    // Attempt to leave
    bool hasLeft = await Provider.of<BoardProvider>(context, listen: false)
        .leaveBoard(boardId);
    if (hasLeft) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DefaultSuccessDialog(
                successMessage: "Left board with id $boardId");
          });
      return hasLeft;
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DefaultErrorDialog(
                errorMessage:
                    "Faild to leave board with id $boardId - please try again");
          });
    }
    return hasLeft;
  }

  Future<bool> _promptLeavingBoard(String boardId) async {
    // Can't leave as the owner - must transfer ownership or delet board
    bool leaving = false;
    if (await Provider.of<BoardProvider>(context, listen: false)
        .checkIfOwner(boardId)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DefaultErrorDialog(
              title: "Unable to Delete",
              errorMessage:
                  "You are the owner of this board. Pass on ownership or delete it instead",
            );
          });
      leaving = false;
    } else {
      leaving = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return const ConfirmationAlertDialog(
              title: "Leave Expense Board",
              content: "Are you sure you want to leave this expense board?",
            );
          }) as bool;
    }
    return leaving;
  }
}
