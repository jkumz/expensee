// Service layer class to handle CRUD API
// May need split into multiple service layer classes if too big - readability

import 'package:expensee/enums/roles.dart';
import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:expensee/main.dart';
import 'package:expensee/models/group_member/group_member.dart';
import 'package:expensee/models/invitation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:resend/resend.dart';

//TODO - proper error handling + logging
//TODO - validation - if member part of board, if already removed, if board exists etc. Go over every method.
//TODO - convert JSON to required format when fetching, may do in classes

class SupabaseService {
  // Using our global Supabase client singleton instance from main.dart

// Fetch expense boards for a user including those where the user is a group member
  Future<List<ExpenseBoard>> getExpenseBoards(
      String userId, bool isGroup) async {
    try {
      // Perform a raw SQL query using a stored procedure
      final response = await supabase.rpc('get_user_boards',
          params: {'user_id_param': userId, 'is_group_param': isGroup});

      // Check if the response contains data and it's a list
      if (response != null && response is List) {
        // Extract the list of data from the response
        final List<dynamic> data = response;

        // Map the dynamic list to a list of ExpenseBoard instances
        return data.where((json) => json != null).map<ExpenseBoard>((json) {
          return ExpenseBoard.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        print('Error: Data is null or not a list');
        return [];
      }
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
    expenseBoardData['creator_id'] = userId;

    final response = await supabase
        .from('expense_boards')
        .insert([expenseBoardData]).select() as List;

    if (response.isNotEmpty) {
      final addedOwner =
          await _addOwnerToBoard(response.first["id"].toString(), userId);

      if (addedOwner) {
        print("Board created & owner added");
      } else {
        print("Error adding owner to expense board - deleting board!");
        await deleteExpenseBoard(response.first["id"].toString());
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

  // Update an expense board - // TODO - test this + validation + error handling
  Future<ExpenseBoard?> updateExpenseBoard(
      String boardId, Map<String, dynamic> updatedData) async {
    final response = await supabase
        .from("expense_boards")
        .update(updatedData)
        .match({'id': boardId}).onError((error, stackTrace) => print(
            "Error updating expense board with id $boardId\nError $error - $stackTrace"));

    final updatedBoard =
        await supabase.from("expense_boards").select().match({'id': boardId});

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

  Future<bool> isBoardOwner(String boardId) async {
    var boardOwnerRecord = (await supabase
            .from("group_members")
            .select()
            .eq("board_id", boardId)
            .eq("role", "owner") as List<dynamic>)
        .firstOrNull;

    if (boardOwnerRecord == null) {
      print("No board with matching id: $boardId");
      return false;
    }
    return supabase.auth.currentUser!.id == boardOwnerRecord["user_id"];
  }

  Future<bool> isAdmin(String boardId) async {
    var board = (await supabase
            .from("group_members")
            .select()
            .match({"id": boardId}).match(
                {"user_id": supabase.auth.currentUser!.id}) as List<dynamic>)
        .firstOrNull;

    if (board == null) {
      print("No board with matching id: $boardId");
      return false;
    }
    return board["role"] == "admin";
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
      String boardId, String email, String newRole) async {
    final response = await supabase.from("group_members").update(
        {'role': newRole}).match({"board_id": boardId, "user_email": email});

    if (response != null) {
      print("Error updating group (id: $boardId) member's role with id $email");
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

  // Store invite token in supabase
  Future<bool> storeSentInviteDetails(
      String boardId, String inviteeEmail, String token, Roles role) async {
    String roleString = role.toString().split(".").last;
    final stored = await supabase.from('invitations').insert({
      'board_id': int.tryParse(boardId),
      'invitee_email': inviteeEmail,
      'token': token,
      'status': 'sent',
      'inviter_id': supabase.auth.currentUser!.id,
      'role': roleString
    }).select();

    if (stored == null) return false;
    return true;
  }

  Future<Invitation?> getInvite(String token) async {
    List<dynamic> inviteData =
        await supabase.from("invitations").select().eq("token", token);
    if (inviteData.isNotEmpty) return Invitation.fromJson(inviteData.first);
  }

// Changes status of invite token, returns token.
// Adds invited user to the board.
  Future<Invitation?> acceptInvite(String token) async {
    List<dynamic> inviteData =
        await supabase.from("invitations").select().eq("token", token);

    if (inviteData.isNotEmpty) {
      var inviteJson = inviteData.first;
      inviteJson["status"] = "accepted";
      await supabase
          .from("invitations")
          .update(inviteJson)
          .match({'token': token});

      Map<String, dynamic> updatedJson = ((await supabase
              .from("invitations")
              .select()
              .eq("token", token)) as List<dynamic>)
          .first;

      if (updatedJson["status"] != "accepted") {
        print("Error updating status of token");
        return null;
      }

      var invitation = Invitation.fromJson(updatedJson);
      bool added = await addMemberToBoard(invitation);
      if (added) {
        print("Successfully accepted invite token $token");
        return Invitation.fromJson(updatedJson);
      }

      // if not added, then change status back and return null
      updatedJson["status"] = "sent";
      print("Failed to add user to board - invite status remains unchanged");
      await supabase
          .from("invitations")
          .update(updatedJson)
          .match({'token': token});
      return null;
    } else {
      print("Failed to fetch invite data for token $token");
      return null;
    }
  }

// Changes status of invite token, returns token.
  Future<Invitation?> declineInvite(String token) async {
    List<dynamic> inviteData =
        await supabase.from("invitations").select().eq("token", token);
    if (inviteData.isNotEmpty) {
      var inviteJson = inviteData.first;
      inviteJson["status"] = "declined";
      await supabase
          .from("invitations")
          .update(inviteJson)
          .match({'token': token});

      Map<String, dynamic> updatedJson = ((await supabase
              .from("invitations")
              .select()
              .eq("token", token)) as List<dynamic>)
          .first;

      if (updatedJson["status"] != "declined") {
        print("Error updating status of token");
        return null;
      }
      print("Declined invite for token $token");
      return Invitation.fromJson(updatedJson);
    } else {
      print("Failed to fetch invite data for token $token");
      return null;
    }
  }

  Future<bool> _addOwnerToBoard(String boardId, String userId) async {
    bool added = true;

    final Map<String, dynamic> ownerJson = {
      "board_id": boardId,
      "user_id": supabase.auth.currentUser!.id,
      "role": "owner",
      "user_email": supabase.auth.currentUser!.email
    };

    try {
      final resp = await supabase
          .from("group_members")
          .insert(ownerJson)
          .select() as List;
      if (resp.isEmpty) {
        print("Failed to add owner for new board");
        return !added;
      }
      added = true;
    } catch (e) {
      //TOOD - handle exception
      print("Failed to add owner for board $boardId");
      return !added;
    }
    return added;
  }

  // Add a new user to a group expense board
  Future<bool> addMemberToBoard(Invitation invitation) async {
    bool added = true;

    try {
      final Map<String, dynamic> groupMemberJson = {
        "board_id": invitation.boardId,
        "user_id": invitation.invitedId,
        "role": invitation.role
            .toString()
            .split(".")
            .last, // default //TODO - RBAC. 3 diff role IDs, with diff perms
        "user_email": invitation.invitedEmail
      };
      final resp =
          await supabase.from("group_members").insert(groupMemberJson).select();

      if (resp == null) {
        print(
            "Failed to add member ${invitation.invitedEmail} to board ${invitation.boardId}");
        return !added;
      }

      print(
          "Added member ${invitation.invitedEmail} to board ${invitation.boardId}");
      return added;
    } catch (e) {
      print("Error: $e\nFailed to add member to board");
    }

    return !added;
  }

  // Get a list of user invites, can filter whether declined or accepted.
  Future<List<Invitation>> getInvitesForMember(
      String email, String status) async {
    List<dynamic> response = await supabase
        .from("invitations")
        .select()
        .eq("invitee_email", email)
        .eq("status", status)
        .order("created_at", ascending: true);

    List<Invitation> invites = [];
    for (var inviteJson in response) {
      invites.add(Invitation.fromJson(inviteJson));
    }
    return invites;
  }

// Get list of group members for an expense bard
  Future<List<GroupMember>> getGroupMembers(
      String boardId, bool isAdmin) async {
    List<GroupMember> members = [];

// if owner, view ALL but your own
    if (!isAdmin) {
      List<dynamic> response = await supabase
          .from("group_members")
          .select()
          .eq("board_id", boardId)
          .neq("user_email", supabase.auth.currentUser!.email);
      for (var memberJson in response) {
        members.add(GroupMember.fromJson(memberJson));
      }
    } else {
      // if admin, only view shareholders
      final response = (await supabase
          .from("group_members")
          .select()
          .eq("board_id", boardId)
          .neq("role", "owner")
          .neq("role", "admin")
          .neq("user_email", supabase.auth.currentUser!.email));
      for (var memberJson in response) {
        members.add(GroupMember.fromJson(memberJson));
      }
    }

    return members;
  }

// Remove a group member from a board using their email address
  Future<bool> removeGroupMember(String boardId, String email) async {
    final resp = await supabase
        .from("group_members")
        .delete()
        .match({"board_id": boardId, "user_email": email});

    if (resp != null) {
      print("Failed to remove $email from board $boardId");
    }
    return resp == null;
  }

  Future<bool> updateBoardName(String boardId, String newName) async {
    final resp =
        await supabase.from("expense_boards").select().eq("id", boardId);

    if (resp == null) return false;

    if (resp is List<dynamic>) {
      resp.first["name"] = newName;
      updateExpenseBoard(boardId, resp.first);
    }
    return true;
  }

// The logic for this is quite simple. We want to make the current user an "admin".
// We want to make the user with "email" as their email address the new owner.
// This means updating both the expense_boards table (owner_id col) and the
// group_members table (adding owner to the table as an Admin, changing other
// user to an Admin) - if any of this fails we want to revert it all back to
// previous state.

// We also want to make sure that the current user is in fact the owner.
  //TODO - proper handling / logging / validation

  Future<bool> transferBoardOwnership(String boardId, String email) async {
    bool transferred = true;
    final userId = supabase.auth.currentUser!.id;
    // 1 - Check if current user is owner
    var currentOwner = (await supabase
            .from("group_members")
            .select()
            .eq("board_id", boardId)
            .eq("role", "owner") as List<dynamic>)
        .first;
    if (currentOwner["user_id"] != userId) {
      print("NOT PERMITTED");
      return !transferred;
    }

    var newOwner = (await supabase
            .from("group_members")
            .select()
            .eq("board_id", boardId)
            .eq("user_email", email) as List<dynamic>)
        .firstOrNull;

    if (newOwner == null || newOwner.isEmpty) {
      print("MEMBER TO TRANSFER TO DOESN'T EXIST!");
      return !transferred;
    }

    // 2 - Add current user as an Admin in Group Members
    final changedToAdmin = await supabase
        .from("group_members")
        .update({"role": "admin"}).match(
            {"board_id": boardId, "user_id": userId}).select();

    // 3 - Change other user to Owner in in Group Members
    final changedToOwner = await supabase.from("group_members").update(
        {"role": "owner"}).match({"board_id": boardId, "user_email": email});

    if (changedToAdmin == null || changedToOwner == null) {
      // error handling
      return !transferred;
    }

    return transferred;
  }

  // Only to be used when rendering a group board.
  Future<String> getMemberRole(String boardId) async {
    final email = supabase.auth.currentUser!.email;
    final memberRecord = (await supabase
            .from("group_members")
            .select()
            .eq("user_email", email)
            .eq("board_id", boardId) as List<dynamic>)
        .firstOrNull;

    if (memberRecord == null) {
      print("Failed to fetch role in board $boardId for $email");
      return "";
      //TODO - proper error handling
    }

    return memberRecord["role"];
  }

  Future<List<String>> getMemberEmails(String boardId, bool adminOnly) async {
    final memberRecordList = (adminOnly
        ? await supabase
            .from("group_members")
            .select()
            .eq("board_id", boardId)
            .neq("role", "shareholder")
        : await supabase
            .from("group_members")
            .select()
            .eq("board_id", boardId)) as List<dynamic>;

// TODO - proper error handling + logging
    if (memberRecordList.isEmpty) {
      print("Failed to get members for board $boardId");
      return [];
    }

    return memberRecordList
        .map((record) => record["user_email"] as String)
        .toList();
  }

  Future<List<String>> fetchCategories(String boardId) async {
    final allCategoryRecords = await supabase
        .from("expenses")
        .select("category")
        .eq("board_id", boardId) as List<dynamic>;

    if (allCategoryRecords.isEmpty) {
      // TODO - proper handling
      print("Failed to fetch categories for board $boardId");
      return List.empty();
    }

    // Get all unique category instances and return as a list
    return allCategoryRecords
        .map((json) => json["category"] as String)
        .toSet()
        .toList();
  }

  Future<List<(String userId, String userEmail)>> fetchMemberRecords(
      String boardId) async {
    final allMemberRecords = await supabase
        .from("group_members")
        .select("user_id, user_email")
        .eq("board_id", boardId) as List<dynamic>;

    if (allMemberRecords.isEmpty) {
      //TODO - proper handling + logging
      print("Failed to fetch member records for board $boardId");
      return List.empty();
    }

    // specifified output of map for clarity - (userId, userEmail) records
    return allMemberRecords.map<(String userId, String userEmail)>((json) {
      return (json['user_id'] as String, json['user_email'] as String);
    }).toList();
  }
}
