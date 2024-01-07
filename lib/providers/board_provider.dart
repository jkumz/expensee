import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/services/supabase_service.dart';
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
  final repo = BoardRepository();
  bool isLoading = false;

  BoardProvider();

// Refresh the list of boards
  Future<List<ExpenseBoard>?> refreshBoards(bool isGroup) async {
    isLoading = true;
    notifyListeners(); // Notify listeners to show the loading indicator

    try {
      _boards = await repo.refreshExpenseBoards(isGroup);
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
    var board = await repo.addExpenseBoard(json);

    if (board != null) {
      print("Created board with name ${json['name']}");
      _boards.add(board);
      notifyListeners();
      return true;
    }
    isLoading = false;
    return false;
  }

// delete a board
  Future<bool> deletedBoard(String boardId) async {
    isLoading = true;
    notifyListeners();
    bool deleted = await repo.removeExpenseBoard(boardId);

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

    var updated = await repo.updateExpenseBoard(boardId, updatedJson);

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
}
