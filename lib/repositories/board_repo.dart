import 'package:expensee/main.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:expensee/repositories/interfaces/board_repo_interface.dart';
import 'package:expensee/services/supabase_service.dart';

// Repository for querying expense boards from Supabase via Service Layer
class BoardRepository implements BoardRepositoryInterface {
  final _userId = supabase.auth.currentUser!.id;
  final _service = SupabaseService();

  @override
  Future<List<ExpenseBoard>> refreshExpenseBoards(bool isGroup) async {
    List<ExpenseBoard> _boardsInJson =
        await _service.getExpenseBoards(_userId, isGroup);

    return _boardsInJson;
  }

  @override
  Future<ExpenseBoard> addExpenseBoard(Map<String, dynamic> json) async {
    try {
      var board = await _service.createExpenseBoard(json);
      return board; // Assuming createExpenseBoard returns an ExpenseBoard object.
    } catch (e) {
      // Handle any errors here
      print('Error adding expense board: $e');
      throw Exception('Failed to add expense board: $e');
    }
  }

  @override
  Future<bool> removeExpenseBoard(String boardId) async {
    final removed = await _service.deleteExpenseBoard(boardId);

    return removed;
  }

  @override
  Future<ExpenseBoard?> updateExpenseBoard(
      String boardId, Map<String, dynamic> json) async {
    var updated = await _service.updateExpenseBoard(boardId, json);

    return updated;
  }

  Future<ExpenseBoard?> getBoard(String boardId) async {
    var board = await _service.getBoard(boardId);

    return board;
  }

  Future<Expense?> getExpense(String expenseId) async {
    var expense = await _service.getExpense(expenseId);
    return expense;
  }

  Future<List<Expense>> getExpenses(String boardId) async {
    List<Expense> expenses = await _service.getExpensesForBoard(boardId);

    return expenses;
  }
}
