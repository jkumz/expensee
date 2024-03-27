import 'package:expensee/models/expense/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import "package:expensee/repositories/board_repo.dart";

var logger = Logger(
  printer: PrettyPrinter(), // Use the PrettyPrinter for easy-to-read logging
);

// TODO - proper error handling + logging
class BoardProvider extends ChangeNotifier {
  List<ExpenseBoard> _boards = [];
  List<ExpenseBoard> get boards => _boards;
  final _repo = BoardRepository();
  bool isLoading = false;

  BoardProvider();

// Refresh the list of boards
  Future<List<ExpenseBoard>?> refreshBoards(bool isGroup) async {
    isLoading = true;
    notifyListeners(); // Notify listeners to show the loading indicator

    try {
      _boards = await _repo.refreshExpenseBoards(isGroup);
      print("Fetched boards: $_boards");
      return _boards;
    } catch (error) {
      print("Error fetching boards: $error");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// add a board
  Future<bool> createBoard(Map<String, dynamic> json) async {
    isLoading = true;
    notifyListeners();
    var board = await _repo.addExpenseBoard(json);

    print("Created board with name ${json['name']}");
    _boards.add(board);
    notifyListeners();
    return true;
  }

// delete a board
  Future<bool> deletedBoard(String boardId) async {
    isLoading = true;
    notifyListeners();
    bool deleted = await _repo.removeExpenseBoard(boardId);

    if (deleted) {
      print("Deleted board with id $boardId");
      _boards.removeWhere((board) => board.id.toString() == boardId);
      notifyListeners();
    }
    isLoading = false;
    return deleted;
  }

// update a board
  Future<bool> updateBoard(
      String boardId, Map<String, dynamic> updatedJson) async {
    isLoading = true;
    notifyListeners(); // Notify to show a loading indicator

    var updated = await _repo.updateExpenseBoard(boardId, updatedJson);

    if (updated != null) {
      // Find the board in the list and update its fields
      int index = _boards.indexWhere((board) => board.id == boardId);
      if (index != -1) {
        _boards[index] = updated;
      } else {
        // If the board doesn't exist, you might want to handle this situation
        logger.w("Board with id $boardId not found for update");
        return false;
      }
      logger.i("Updated board with id $boardId");
    } else {
      logger.e("Failed to update board with id $boardId");
      return false;
    }

    isLoading = false;
    notifyListeners(); // Notify to hide loading indicator and refresh UI

    return true;
  }

  Future<ExpenseBoard?> updateBoardWithExpense(
      String boardId, String expenseId) async {
    isLoading = true;
    notifyListeners();

    // find board with id, then update it with new expense / refresh it
    ExpenseBoard? board = await getBoardWithId(boardId);
    Expense? expense = await _repo.getExpense(expenseId);
    if (expense != null && board != null) {
      board.expenses.add(expense);
      return board;
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<ExpenseBoard?> fetchBoardExpenses(String boardId) async {
    isLoading = true;
    notifyListeners();

    // fetch board and its expenses
    ExpenseBoard? board = await getBoardWithId(boardId);
    final expenses = await _repo.getExpenses(boardId);

    if (board != null) {
      // update board balance based on expenses
      var balanceAfterExpenses = board.initialBalance;
      expenses.forEach((element) {
        balanceAfterExpenses -= element.amount;
      });

      // then update individual expense balances
      balanceAfterExpenses =
          (await _repo.getBoard(boardId) as ExpenseBoard).initialBalance;
      for (Expense expense in expenses) {
        balanceAfterExpenses -= expense.amount;
        expense.balance = balanceAfterExpenses;
      }

      // assign board expenses
      board.expenses = expenses;

      // if balances aren't matched, update the board balance
      if (balanceAfterExpenses != board.balance) {
        var newBoardJson = board.toJson();
        newBoardJson["balance"] = balanceAfterExpenses;
        updateBoard(boardId, newBoardJson);
      }

      logger.i("Board with id $boardId has refreshed.");
    } else {
      logger.e("Board with id $boardId has failed to referesh");
    }
    notifyListeners();
    return board;
  }

  Future<ExpenseBoard?> getBoardWithId(String boardId) async {
    return await _repo.getBoard(boardId);
  }

  Future<ExpenseBoard?> refreshBoardBalance(String boardId) async {
    return fetchBoardExpenses(boardId);
  }

  Future<String> getBoardName(String boardId) async {
    ExpenseBoard? board = await _repo.getBoard(boardId);
    if (board != null) return board.name;
    return "Expense Board";
  }

  Future<double> getBoardBalance(String boardId) async {
    ExpenseBoard? board = await _repo.getBoard(boardId);
    if (board != null) return board.balance;
    return 0.00;
  }

  Future<bool> checkIfOwner(String boardId) async {
    bool owner = await _repo.isOwner(boardId);
    return owner;
  }

  Future<bool> checkIfAdmin(String boardId) async {
    bool admin = await _repo.isAdmin(boardId);
    return admin;
  }

  Future<bool> updateBoardName(String boardId, String newName) async {
    return await _repo.updateName(boardId, newName);
  }
}
