import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class ExpenseProvider extends ChangeNotifier {
  final _repo = ExpenseRepository();
  bool isLoading = false;
  Expense _expense = Expense.blank();
  Expense get expense => _expense;
  List<Expense> _expenseList = [];
  List<Expense> get expenseList => _expenseList;

  ExpenseProvider();

  Future<List<Expense>> refreshExpensesForBoard(String boardId) async {
    isLoading = true;
    notifyListeners();

    try {
      _expenseList = await _repo.refreshExpensesForBoard(boardId);
      logger.i("Refreshed expenses for board with id $boardId");
    } catch (e) {
      logger.e("Failed to refresh expenses for board with id $boardId");
    }

    return _expenseList;
  }

  Future<Expense> refreshExpense(expenseId) async {
    isLoading = true;
    notifyListeners();

    try {
      _expense = await _repo.refreshExpense(expenseId);
      logger.i("Refreshed expenses for board with id $expenseId");
    } catch (e) {
      logger.e("Failed to refresh board with id $expenseId");
    }

    isLoading = false;
    notifyListeners();
    return _expense;
  }

  Future<Expense> addExpense(Map<String, dynamic> json) async {
    isLoading = true;
    notifyListeners();

    _expense = await _repo.addExpense(json);
    logger.i("Added expense with id ${json['id']}");
    logger.e("Failed to add new expense with id ${json['id']}");

    isLoading = false;
    notifyListeners();
    return _expense;
  }

  Future<Expense> removeExpense(int expenseId) async {
    isLoading = true;
    notifyListeners();

    try {
      var removedExpense = await _repo.removeExpense(expenseId);
      if (removedExpense != null) _expense = removedExpense;
      logger.i("Removed expense with id $expenseId");
    } catch (e) {
      logger.e("Failed to remove expense with id $expenseId");
    }

    isLoading = false;
    notifyListeners();
    return _expense;
  }

  Future<Expense> updateExpense(
      Map<String, dynamic> updatedJson, String expenseId) async {
    isLoading = true;
    notifyListeners();

    try {
      _expense = await _repo.updateExpense(expenseId, updatedJson);
      logger.i("Updated expense with id $expenseId");
    } catch (e) {
      logger.e(
          "Failed to update expense with id $expenseId using data $updatedJson");
    }

    isLoading = false;
    notifyListeners();
    return _expense;
  }

  Future<bool> isPartOfGroupBoard(String boardId) async {
    return await _repo.isPartOfGroup(boardId);
  }

  Future<String?> addReceipt(BuildContext context, int expenseId) async {
    return await _repo.addReceipt(context, expenseId);
  }

  Future<bool> uploadReceiptUrl(int expenseId, String? addedReceiptUrl) async {
    return _repo.uploadReceiptUrl(expenseId, addedReceiptUrl);
  }

  Future<Image> getReceiptForExpense(int expenseId) async {
    var url = await _repo.getReceiptForExpense(expenseId);
    return Image.network(url);
  }

  Future<String> getReceiptUrlForExpense(int expenseId) async {
    return await _repo.getReceiptForExpense(expenseId);
  }

  Future<bool> hasReceipt(int expenseId) async {
    return await _repo.hasReceipt(expenseId);
  }

  Future<bool> deleteReceipt(int expenseId) async {
    return await _repo.deleteReceipt(expenseId);
  }

// Gets all expenses, then verifies the date is within the specified boundary
// or on the individual date. If it is, it adds it to the expense list, then
// returns a list of the IDs of the expenses that meet our date criteria.
// HELPER method for downloading all receipts for a board.
  Future<List<int>> getExpenseIdsForBoardWithDate(
      String boardId, String? startDate, String? endDate) async {
    isLoading = true;
    notifyListeners();

    try {
      List<Expense> expenseList = await _repo.refreshExpensesForBoard(boardId);
      logger.i("Fetched expense IDs for board $boardId");

      // Convert startDate and endDate strings to DateTime objects
      DateTime? start = startDate != null ? DateTime.parse(startDate) : null;
      DateTime? end = endDate != null ? DateTime.parse(endDate) : start;

      if (start != null && end != null && start != end) {
        // Filter expenses that fall within the range
        var temp = expenseList
            .where((Expense e) =>
                e.date.isAfter(start.subtract(const Duration(days: 1))) &&
                e.date.isBefore(end.add(const Duration(days: 1))))
            .toList();
        _expenseList = temp;
      } else if (start != null) {
        // If only start date is provided, filter expenses for that specific day
        expenseList = expenseList
            .where((Expense e) => e.date.isAtSameMomentAs(start))
            .toList();
        _expenseList = expenseList;
      }
      // Else, if no dates are provided, return all expenses as is
    } catch (e) {
      logger.e("Failed to fetch expense IDs for board with id $boardId: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return _expenseList.map((Expense e) => e.id!).toList();
  }

  Future<List<int>> getExpenseIdsForBoard(String boardId) async {
    isLoading = true;
    notifyListeners();

    try {
      List<Expense> expenseList = await _repo.refreshExpensesForBoard(boardId);
      _expenseList = expenseList;
      logger.i("Fetched expense IDs for board $boardId");
    } catch (e) {
      logger.e("Failed to fetch expense IDs for board with id $boardId: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return _expenseList.map((Expense e) => e.id!).toList();
  }
}
