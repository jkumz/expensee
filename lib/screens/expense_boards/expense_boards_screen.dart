import 'package:expensee/components/appbars/view_boards_app_bar.dart';
import 'package:expensee/components/bottom_bars/default_bottom_bar.dart';
import 'package:expensee/components/buttons/custom_callback_button.dart';
import 'package:expensee/components/lists/expense_list.dart';
import 'package:expensee/repositories/board_repo.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/home.dart';
import 'package:flutter/material.dart';
import "package:expensee/models/expense_board/expense_board.dart";

class ViewExpenseBoards extends StatefulWidget {
  static const routeName = "/expense-boards";
  final bool isGroupBoardScreen;

  const ViewExpenseBoards({super.key, required this.isGroupBoardScreen});

  @override
  State<StatefulWidget> createState() => _ViewExpenseBoardState();
}

class _ViewExpenseBoardState extends State<ViewExpenseBoards> {
  late List<ExpenseBoard> boards = [];
  bool isLoading = true;
  final _repo = BoardRepository();

  @override
  void initState() {
    super.initState();
    getAllExpenseBoards(widget.isGroupBoardScreen).then((fetchedBoards) {
      print(fetchedBoards);
      setState(() {
        boards = fetchedBoards;
        isLoading = false;
      });
    });
  }

// Helper method for updating state upon navigating back via a pop
  void _fetchBoards() async {
    var fetchedBoards =
        await _repo.refreshExpenseBoards(widget.isGroupBoardScreen);

    setState(() {
      boards = fetchedBoards;
    });
  }

// Update state upon popping back to this screen with correct boards
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ViewBoardsAppBar(
          actions: [
            //TODO - Add expense board button
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : buildBoardListView(boards),
        bottomNavigationBar: DefaultBottomAppBar());
  }

// TODO - Connect to API, pull and process!
  Future<List<ExpenseBoard>> getAllExpenseBoards(bool isGroup) async {
    final _list = await _repo.refreshExpenseBoards(isGroup);

    return _list;
  }

  Future<bool> deleteBoardWithId(String boardId) async {
    final deleted = await _repo.removeExpenseBoard(boardId);

    return deleted;
  }

  buildBoardListView(List<ExpenseBoard> boards) {
    return Column(children: [
      boards.isEmpty
          ? Center(
              child: Text("No expense boards"),
            )
          : Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final board = boards[index];
                  return Dismissible(
                    key: Key(board.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                    secondaryBackground:
                        Container(color: Color.fromARGB(255, 255, 255, 255)),
                    onDismissed: (direction) => {
                      if (direction == DismissDirection.endToStart)
                        {
                          deleteBoardWithId(board.id.toString()),
                          setState(() => boards.removeAt(index))
                        }
                    },
                    confirmDismiss: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        // Disable right swipe
                        return Future.value(false);
                      }
                      // Enable left swipe
                      return Future.value(true);
                    },
                    child: ListTile(
                      title: Text(
                        "Board Name: ${boards[index].name}",
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        // Navigate to the the right board
                      },
                    ),
                  );
                },
                itemCount: boards.length,
              ),
            ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: IconButton(
          icon: Image.asset("assets/images/add.png",
              fit: BoxFit.contain, width: 50, height: 50),
          onPressed: () => _navigateAndRefresh(),
        ),
      )
    ]);
  }

  Future<void> _navigateAndRefresh() async {
    // Navigate and wait for result
    await Navigator.of(context).pushNamed(BoardCreationScreen.routeName);

    _fetchBoards();
  }
}
