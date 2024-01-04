import 'package:expensee/models/expense_board/expense_board.dart';

abstract class BoardRepositoryInterface {
  Future<List<ExpenseBoard>> refreshExpenseBoards(bool isGroup);
  Future<bool> addExpenseBoard(Map<String, dynamic> json);
  Future<bool> removeExpenseBoard(String boardId);
  Future<bool> updateExpenseBoard(String boardId, Map<String, dynamic> json);
}
