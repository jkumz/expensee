// Service layer class to handle CRUD API
// May need split into multiple service layer classes if too big - readability

import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensee/main.dart';

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
      return data.map<ExpenseBoard>((json) {
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
  Future<bool> createExpenseBoard(Map<String, dynamic> expenseBoardData) async {
    final _userId = supabase.auth.currentUser!.id;
    expenseBoardData['owner_id'] = _userId;

    final response =
        await supabase.from('expense_boards').insert([expenseBoardData]);

    if (response != null) {
      if (response.error != null) {
        // Handle error
        print('Error creating expense board');
        return false;
      }
    }
    return true;
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

  // Update an expense board
  Future<bool> updateExpenseBoard(
      String boardId, Map<String, dynamic> updatedData) async {
    final response = await supabase
        .from("expense_boards")
        .update(updatedData)
        .match({'id': boardId});

    if (response.error != null && response != null) {
      print("Error updating expense board with id $boardId");
      return false;
    }
    return true;
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

  // Get expenses for a board
  Future<List<Expense>> getExpensesForBoard(String boardId) async {
    final response = await supabase.from('expenses').select().eq('id', boardId);

    if (response != null) {
      // Handle error
      print('Error fetching expenses');
      return [];
    }

    return response.data.map<Expense>((json) => Expense.fromJson(json));
  }

  // Update an expense
  Future<bool> updateExpense(
      String expenseId, Map<String, dynamic> expenseData) async {
    final response = await supabase
        .from("expenses")
        .update(expenseData)
        .match({'id': expenseId});

    if (response != null) {
      print("Error updating expense board with id $expenseId");
      return false;
    }
    return true;
  }

// Add expenses to a board
  Future<bool> addExpense(Map<String, dynamic> expenseData) async {
    final response = await supabase.from('expenses').insert([expenseData]);

    if (response != null) {
      // Handle error
      print('Error adding expense');
      return false;
    }
    return true;
  }

  // Remove expense
  Future<bool> removeExpense(String expenseId) async {
    final response =
        await supabase.from('expenses').delete().match({'id': expenseId});

    if (response.error != null && response != null) {
      print("Failed to delete expense with id $expenseId");
      return false;
    }
    return true;
  }
}
