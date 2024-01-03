import 'package:expensee/main.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/repositories/interfaces/expense_repo_interface.dart';
import 'package:expensee/services/supabase_service.dart';

class ExpenseRepositories implements ExpenseRepositoryInterface {
  final _service = SupabaseService();

  @override
  Future<List<Expense>> refreshExpenses(boardId) async {
    List<Expense> _expenses = await _service.getExpensesForBoard(boardId);

    return _expenses;
  }

  @override
  Future<bool> addExpense(Map<String, dynamic> json) {
    final _added = _service.addExpense(json);

    return _added;
  }

  @override
  Future<bool> removeExpense(String expenseId) {
    final _removed = _service.removeExpense(expenseId);

    return _removed;
  }

  @override
  Future<bool> updateExpense(String expenseId, Map<String, dynamic> json) {
    final _updated = _service.updateExpense(expenseId, json);

    return _updated;
  }
}
