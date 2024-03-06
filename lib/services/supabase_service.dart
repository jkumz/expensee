// Service layer class to handle CRUD API
// May need split into multiple service layer classes if too big - readability

import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:expensee/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:resend/resend.dart';

//TODO - proper error handling + logging
//TODO - validation
//TODO - convert JSON to required format when fetching, may do in classes

class SupabaseService {
  // Using our global Supabase client singleton instance from main.dart

  // Fetch expense boards for a user
  Future<List<ExpenseBoard>> getExpenseBoards(
      String userId, bool isGroup) async {
    try {
      final result = await supabase
          .from('expense_boards')
          .select()
          .eq('owner_id', userId)
          .eq('is_group', isGroup);

      // Here, 'result' should be a List<dynamic> containing the data
      final data =
          result as List<dynamic>; // Cast the result to a List<dynamic>

      // Map the dynamic list to a list of ExpenseBoard instances
      return data.where((json) => json != null).map<ExpenseBoard>((json) {
        return ExpenseBoard.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      // If there's an error, log it and return an empty list
      print('Error fetching expense boards - Group: $isGroup');
      print('Error: $error');
      return [];
    }
  }

  // Create a new expense board
  Future<ExpenseBoard> createExpenseBoard(
      Map<String, dynamic> expenseBoardData) async {
    final userId = supabase.auth.currentUser!.id;
    expenseBoardData['owner_id'] = userId;

    final response =
        await supabase.from('expense_boards').insert([expenseBoardData]);

    if (response != null) {
      if (response.error != null) {
        // Handle error
        print('Error creating expense board');
      }
    }
    return ExpenseBoard.fromJson(expenseBoardData);
  }

// Delete an expense board
  Future<bool> deleteExpenseBoard(String boardId) async {
    final resp =
        await supabase.from('expense_boards').delete().match({'id': boardId});

    if (resp != null) {
      print("Error deleting expense board with ID $boardId");
      return false;
    }
    return true;
  }

  // Update an expense board - / TODO - test this!
  Future<ExpenseBoard?> updateExpenseBoard(
      String boardId, Map<String, dynamic> updatedData) async {
    final response = await supabase
        .from("expense_boards")
        .update(updatedData)
        .match({'id': boardId});

    if (response != null) {
      print("Error updating expense board with id $boardId");
    }
    return ExpenseBoard.fromJson(updatedData);
  }

  Future<ExpenseBoard?> getBoard(String boardId) async {
    var board =
        await supabase.from("expense_boards").select().match({"id": boardId});

    if (board == null) {
      print("No board with matching id: $boardId");
    }
    board = ExpenseBoard.fromJson(board[0]);
    return board;
  }

  // Add a new user to a group expense board
  Future<bool> addMemberToBoard(
      String boardId, Map<String, dynamic> memberData) async {
    final response = await supabase.from('group_members').insert([memberData]);

    if (response.error != null && response != null) {
      // Handle error
      print(
          'Error adding member with id ${memberData["id"]} to board with id $boardId');
      return false;
    }
    return true;
  }

  // Remove a user from an expense board
  Future<bool> deleteGroupMember(String boardId, String userId) async {
    final response = await supabase
        .from('group_members')
        .delete()
        .match({'id': boardId, 'user_id': userId});

    if (response.error != null && response != null) {
      print(
          'Error deleting group member with id $userId from board with id $boardId');
      return false;
    }

    return true;
  }

  Future<bool> updateGroupMemberRole(
      String boardId, String userId, String newRole) async {
    final response =
        await supabase.from("group_members").update({'role': newRole});

    if (response.error != null && response != null) {
      print(
          "Error updating group (id: $boardId) member's role with id $userId");
      return false;
    }
    return true;
  }

  Future<bool> isBoardGroup(String boardId) async {
    final jsonList =
        await supabase.from("expense_boards").select().eq("id", boardId);
    return jsonList[0]["is_group"];
  }

  // Get expenses for a board in ascending format by date
  Future<List<Expense>> getExpensesForBoard(String boardId) async {
    List<dynamic> response = await supabase
        .from('expenses')
        .select()
        .eq('board_id', boardId)
        .order('created_at', ascending: true);

    List<Expense> expenses = [];
    for (var expenseJson in response) {
      var e = Expense.fromJson(expenseJson);
      e.setId(expenseJson["id"]);
      expenses.add(e);
    }

    return expenses;
  }

  Future<Expense> getExpense(String expenseId) async {
    final expenseExists =
        await supabase.from('expenses').select().eq('id', expenseId);

    if (expenseExists != null) {
      print("Found expense with id $expenseId");
      List<dynamic> expenseJson =
          await supabase.from('expenses').select().eq('id', expenseId);

      Map<String, dynamic> json = expenseJson.first;
      var expense = Expense.fromJson(json);
      expense.id = json['id'];

      return expense;
    }

    print("Expense with id $expenseId doesn't exist");
    return Expense.blank();
  }

  // Update an expense - pull list of JSON, convert item to map
  // Repeat after update and compare. If the same then update failed
  // TODO - dynamic balance adjustment
  Future<Expense> updateExpense(
      String expenseId, Map<String, dynamic> expenseData) async {
    var currentExpense = await getExpense(expenseId);
    Map<String, dynamic> expenseJson = (await supabase
            .from("expenses")
            .select()
            .eq('id', currentExpense.id) as List<dynamic>)
        .firstOrNull;

    // Pull expense before update
    Map<String, dynamic> jsonBeforeUpdate = (await supabase
            .from("expenses")
            .select()
            .eq("id", expenseId) as List<dynamic>)
        .first;

    Expense expense = Expense.fromJson(expenseJson);
    expense.id = expenseJson['id'];

    // Go thru each k-v pair in jsonBeforeUpdate and compare it to expenseData
    // If value in new json is null or blank, assign it to previous value

    expenseData.forEach((key, value) {
      if (value is DateTime) {
        expenseData[key] = expenseDateToString(value);
      } else if (value == null || value == "") {
        expenseData[key] = jsonBeforeUpdate[key];
      }
    });

    await supabase
        .from("expenses")
        .update(expenseData)
        .match({'id': expenseId});

    Map<String, dynamic> updatedJson = (await supabase
            .from('expenses')
            .select()
            .eq('id', expenseId) as List<dynamic>)
        .firstOrNull;
    Expense updatedExpense = Expense.fromJson(updatedJson);

    if (Expense.equals(expense, updatedExpense)) {
      print("Error updating expense board with id $expenseId");
    }

    return updatedExpense;
  }

// Add expenses to a board
  Future<Expense> addExpense(Map<String, dynamic> expenseData) async {
    var added = await supabase.from('expenses').insert([expenseData]).select();

    if (added == null) {
      // Handle error
      print('Error adding expense from provided data: $expenseData');
      return Expense.blank();
    }
    var insertedExpenseData = added as List<dynamic>;
    var id = insertedExpenseData.first['id'];
    var e = Expense.fromJson(expenseData);
    e.setId(id);
    return e;
  }

  // Remove expense
  Future<Expense?> removeExpense(int expenseId) async {
    List<dynamic> expenseData =
        await supabase.from('expenses').select().eq('id', expenseId);
    Expense expense = Expense.fromJson(expenseData.first);
    final response =
        await supabase.from('expenses').delete().match({'id': expenseId});

    if (response != null) {
      print("Failed to delete expense with id $expenseId");
      return null;
    }

    print("Deleted expense with id $expenseId");
    return expense;
  }

// Deno implementation
  // Future<void> sendInvite(String email, String message, String subject) async {
  //   String debugDenoServer = "http:/localhost:8000";
  //   const senderEmail = "ExpenSee <onboarding@resend.dev>";
  //   final url = Uri.parse(debugDenoServer);
  //   final resendApiKey = dotenv.env["RESEND_API_KEY"];

  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $resendApiKey'
  //     },
  //     body: jsonEncode({
  //       "from": [senderEmail],
  //       "to": [email], // The recipient's email address is dynamically set here
  //       "subject": [subject],
  //       "text": [message]
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     print('Email sent successfully: ${response.body}');
  //   } else {
  //     print('Failed to send email: ${response.statusCode}, ${response.body}');
  //   }
  // }

  Future<void> sendInvite(String email, String msg, String subject) async {
    var resend = Resend(apiKey: "${dotenv.env['RESEND_API_KEY']}");
    resend = Resend.instance; // check if api key is correct
    try {
      resend.sendEmail(
          from: "onboarding@resend.dev",
          to: [email],
          subject: subject,
          text: msg);
    } catch (e) {
      print(e);
    }
  }
}
