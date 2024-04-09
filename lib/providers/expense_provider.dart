import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class ExpenseProvider extends ChangeNotifier {
  final _repo = ExpenseRepository();
  final boardId;
  bool isLoading = false;
  Expense _expense = Expense.blank();
  Expense get expense => _expense;
  List<Expense> _expenseList = [];
  List<Expense> get expenseList => _expenseList;

  ExpenseProvider(this.boardId);

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

  Future<bool> hasReceipt(int expenseId) async {
    return await _repo.hasReceipt(expenseId);
  }

  Future<bool> deleteReceipt(int expenseId) async {
    return await _repo.deleteReceipt(expenseId);
  }
}
