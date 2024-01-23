import 'package:expensee/main.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/repositories/interfaces/expense_repo_interface.dart';
import 'package:expensee/services/supabase_service.dart';

class ExpenseRepository implements ExpenseRepositoryInterface {
  final _service = SupabaseService();

  @override
  Future<Expense> refreshExpense(expenseId) async {
    Expense expenseRefreshed = await _service.getExpense(expenseId);

    return expenseRefreshed;
  }

  @override
  Future<Expense> addExpense(Map<String, dynamic> json) async {
    final expenseToAdd = await _service.addExpense(json);

    return expenseToAdd;
  }

  @override
  Future<Expense?> removeExpense(int expenseId) async {
    final removedExpense = await _service.removeExpense(expenseId);

    return removedExpense;
  }

  @override
  Future<Expense> updateExpense(
      String expenseId, Map<String, dynamic> json) async {
    final updated = await _service.updateExpense(expenseId, json);

    return updated;
  }

  @override
  Future<List<Expense>> refreshExpensesForBoard(String boardId) async {
    final expensesRefreshed = await _service.getExpensesForBoard(boardId);

    return expensesRefreshed;
  }

  @override
  Future<bool> isPartOfGroup(String boardId) async {
    bool isGroup = await _service.isBoardGroup(boardId);
    return isGroup;
  }
}