import 'package:expensee/main.dart';
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
  Future<bool> addExpenseBoard(Map<String, dynamic> json) async {
    final _added = await _service.createExpenseBoard(json);

    return _added;
  }

  @override
  Future<bool> removeExpenseBoard(String boardId) async {
    final removed = await _service.deleteExpenseBoard(boardId);

    return removed;
  }

  @override
  Future<bool> updateExpenseBoard(
      String boardId, Map<String, dynamic> json) async {
    bool updated = await _service.updateExpenseBoard(boardId, json);

    return updated;
  }
}
