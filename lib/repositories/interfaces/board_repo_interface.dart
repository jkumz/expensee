import 'package:expensee/models/expense_board/expense_board.dart';

abstract class BoardRepositoryInterface {
  Future<List<ExpenseBoard>> refreshExpenseBoards(bool isGroup);
  Future<ExpenseBoard> addExpenseBoard(Map<String, dynamic> json);
  Future<bool> removeExpenseBoard(String boardId);
  Future<ExpenseBoard?> updateExpenseBoard(
      String boardId, Map<String, dynamic> json);
}
