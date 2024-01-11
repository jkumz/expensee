import 'package:expensee/models/expense/expense_model.dart';

abstract class ExpenseRepositoryInterface {
  Future<Expense> refreshExpense(boardId);
  Future<Expense> updateExpense(String expenseId, Map<String, dynamic> json);
  Future<Expense> addExpense(Map<String, dynamic> json);
  Future<Expense?> removeExpense(int expenseId);
  Future<List<Expense>> refreshExpensesForBoard(String boardId);
  Future<bool> isPartOfGroup(String boardId);
}
