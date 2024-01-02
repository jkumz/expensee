// Service layer class to handle CRUD API
// May need split into multiple service layer classes if too big - readability

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensee/main.dart';

//TODO - proper error handling + logging
//TODO - validation
//TODO - convert JSON to required format when fetching, may do in classes

class SupabaseService {
  // Using our global Supabase client singleton instance from main.dart

  // Fetch expense boards for a user
  Future<List<Map<String, dynamic>>> getExpenseBoards(String userId) async {
    final response =
        await supabase.from('expense_boards').select().eq('owner_id', userId);

    if (response.error != null && response != null) {
      // Handle error
      print('Error fetching expense boards: ${response.error!.message}');
      return [];
    }

    return List<Map<String, dynamic>>.from(response.data);
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
        print('Error creating expense board: ${response.error!.message}');
        return false;
      }
    }
    return true;
  }

// Delete an expense board
  Future<bool> deleteExpenseBoard(String boardId) async {
    final resp = await supabase
        .from('expense_boards')
        .delete()
        .match({'board_id': boardId});

    if (resp.error != null) {
      print("Error deletinv expense board with ID $boardId");
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
      print("Error updating expense boardL ${response.error!.message}");
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
      print('Error adding member: ${response.error!.message}');
      return false;
    }
    return true;
  }

  // Remove a user from an expense board
  Future<bool> deleteGroupMember(String boardId, String userId) async {
    final response = await supabase
        .from('group_members')
        .delete()
        .match({'board_id': boardId, 'user_id': userId});

    if (response.error != null && response != null) {
      print('Error deleting group member: ${response.error!.message}');
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
  Future<List<Map<String, dynamic>>> getExpensesForBoard(String boardId) async {
    final response =
        await supabase.from('expenses').select().eq('board_id', boardId);

    if (response.error != null && response != null) {
      // Handle error
      print('Error fetching expenses: ${response.error!.message}');
      return [];
    }

    return List<Map<String, dynamic>>.from(response.data);
  }

  // Update an expense
  Future<bool> updateExpense(
      String expenseId, Map<String, dynamic> expenseData) async {
    final response = await supabase
        .from("expenses")
        .update(expenseData)
        .match({'id': expenseId});

    if (response.error != null && response != null) {
      print("Error updating expense board with id $expenseId");
      return false;
    }
    return true;
  }

// Add expenses to a board
  Future<bool> addExpense(Map<String, dynamic> expenseData) async {
    final response = await supabase.from('expenses').insert([expenseData]);

    if (response.error != null && response != null) {
      // Handle error
      print('Error adding expense: ${response.error!.message}');
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
