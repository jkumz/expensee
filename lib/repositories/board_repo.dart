import 'package:expensee/main.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:expensee/repositories/interfaces/board_repo_interface.dart';
import 'package:expensee/services/email_service.dart';
import 'package:expensee/services/supabase_service.dart';

// Repository for querying expense boards from Supabase via Service Layer
class BoardRepository implements BoardRepositoryInterface {
  final _userId = supabase.auth.currentUser!.id;
  final _service = SupabaseService();
  final _emailService = EmailService();

  @override
  Future<List<ExpenseBoard>> refreshExpenseBoards(bool isGroup) async {
    List<ExpenseBoard> boardsInJson =
        await _service.getExpenseBoards(_userId, isGroup);

    return boardsInJson;
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

  Future<bool> leaveBoard(String boardId) async {
    return await _service.deleteGroupMember(
        boardId, supabase.auth.currentUser!.id);
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

  Future<bool> isOwner(String boardId) async {
    return await _service.isBoardOwner(boardId);
  }

  Future<bool> isAdmin(String boardId) async {
    return await _service.isAdmin(boardId);
  }

  Future<bool> updateName(String boardId, String newName) async {
    return await _service.updateBoardName(boardId, newName);
  }

  Future<List<String>> getMemberEmails(String boardId, bool adminOnly) async {
    return await _service.getMemberEmails(boardId, adminOnly);
  }

  Future<bool> sendMassEmail(
      String subject, String body, List<String> recipients) async {
    return _emailService.sendEmailNotification(recipients, subject, body);
  }

  Future<List<String>> fetchCategories(String boardId) async {
    return await _service.fetchCategories(boardId);
  }

  Future<List<(String userId, String userEmail)>> fetchMemberRecords(
      String boardId) async {
    return await _service.fetchMemberRecords(boardId);
  }

  Future<List<Expense>> getExpensesWithFilter(
      List<String> userIDs,
      List<String> categories,
      String startDate,
      String endDate,
      String boardId,
      bool invertDates,
      bool invertCategories,
      bool invertUsers) async {
    List<Expense> expenses = await _service.getExpensesWithFilter(
        userIDs, categories, startDate, endDate, boardId,
        invertCategories: invertCategories,
        invertDates: invertDates,
        invertIds: invertUsers);

    return expenses;
  }
}
