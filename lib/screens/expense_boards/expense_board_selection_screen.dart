import 'package:expensee/components/appbars/view_boards_app_bar.dart';
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
    setState(() {
      if (temp != null) boards = temp;
    });
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

  Future<bool> _deleteBoard(String boardId, BuildContext context) async {
    try {
      // Delete
      final deleted = await Provider.of<BoardProvider>(context, listen: false)
          .deletedBoard(boardId);
      return deleted;
    } catch (error) {}
    return false;
  }

  void _navigateToExpenseBoard(BuildContext context, String boardId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) => BoardProvider(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => ExpenseProvider(boardId),
                    ),
                    ChangeNotifierProvider(create: (_) => GroupMemberProvider())
                  ],
                  child: ExpenseBoardScreen(boardId: boardId),
                )));
  }

  Widget _buildBoardItem(ExpenseBoard board, BuildContext context) {
    return Dismissible(
      key: Key(board.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteBoard(board.id.toString(), context);
        }
      },
      background: Container(color: Colors.white),
      child: ListTile(
        title: Center(child: Text(board.name)),
        onTap: () => _navigateToExpenseBoard(context, board.id.toString()),
      ),
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
}
