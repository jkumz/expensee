import 'package:expensee/models/expense/expense_model.dart';

abstract class ExpenseRepositoryInterface {
  Future<List<Expense>> refreshExpenses(boardId);
  Future<bool> updateExpense(String expenseId, Map<String, dynamic> json);
  Future<bool> addExpense(Map<String, dynamic> json);
  Future<bool> removeExpense(String expenseId);
}
