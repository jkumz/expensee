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
import 'package:logger/logger.dart';

import 'package:resend/resend.dart';

//TODO - proper error handling
//TODO - validation - if member part of board, if already removed, if board exists etc. Go over every method.
//TODO - convert JSON to required format when fetching, may do in classes

var logger = Logger(
  printer: PrettyPrinter(), // Use the PrettyPrinter for easy-to-read logging
);

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

        logger
            .d("Fetching expense boards for user ID $userId - group: $isGroup");
        // Map the dynamic list to a list of ExpenseBoard instances
        return data.where((json) => json != null).map<ExpenseBoard>((json) {
          return ExpenseBoard.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        logger.e('Error: Data is null or not a list');
        return [];
      }
    } catch (error) {
      // If there's an error, log it and return an empty list
      logger.e('Error fetching expense boards - Group: $isGroup');
      logger.e('Error: $error');
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
        logger.d("Board created & owner added");
      } else {
        logger.e("Error adding owner to expense board - deleting board!");
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
      logger.e("Error deleting expense board with ID $boardId");
      return false;
    } else {
      logger.d("Deleted expense board with ID $boardId");
    }
    return true;
  }

  // Update an expense board - // TODO - validation + error handling
  Future<ExpenseBoard?> updateExpenseBoard(
      String boardId, Map<String, dynamic> updatedData) async {
    await supabase.from("expense_boards").update(updatedData).match({
      'id': boardId
    }).onError((error, stackTrace) => logger.e(
        "Error updating expense board with id $boardId\nError $error - $stackTrace"));

    final updatedBoardJson = (await supabase
            .from("expense_boards")
            .select()
            .match({'id': boardId}) as List<dynamic>)
        .first;

    ExpenseBoard newBoard = ExpenseBoard.fromJson(updatedData);

    if (!ExpenseBoard.fromJson(updatedBoardJson).equals(newBoard)) {
      logger.e("Error updating expense board with id $boardId");
    } else {
      logger.d("Updated expense board with id $boardId");
    }
    return newBoard;
  }

  Future<ExpenseBoard?> getBoard(String boardId) async {
    var board =
        await supabase.from("expense_boards").select().match({"id": boardId});

    if (board == null) {
      logger.e("No board with matching id: $boardId");
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
      logger.e("No board with matching id: $boardId");
      return false;
    }

    logger
        .d("Checing if current user is board owner of board with ID $boardId");
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
      logger.e("No board with matching id: $boardId");
      return false;
    }
    logger.d("Checing if current user is an admin of board with ID $boardId");

    return board["role"] == "admin";
  }

  // Remove a user from an expense board
  Future<bool> deleteGroupMember(String boardId, String userId) async {
    final response = await supabase
            .from('group_members')
            .delete()
            .match({'board_id': boardId, 'user_id': userId}).select()
        as List<dynamic>;

    if (response.isEmpty) {
      logger.e(
          'Error deleting group member with id $userId from board with id $boardId');
      return false;
    }

    logger.d(
        "Successfully deleted user with ID $userId from board with ID $boardId");
    return true;
  }

  Future<bool> updateGroupMemberRole(
      String boardId, String email, String newRole) async {
    final response = await supabase.from("group_members").update(
        {'role': newRole}).match({"board_id": boardId, "user_email": email});

    if (response != null) {
      logger.e(
          "Error updating group (board id: $boardId) member's role with email $email");
      return false;
    }
    logger.d(
        "Successfully updated group (board id: $boardId) member's role with email $email");
    return true;
  }

  Future<bool> isBoardGroup(String boardId) async {
    final jsonList =
        await supabase.from("expense_boards").select().eq("id", boardId);
    logger.d("Checking if board with id $boardId is a group board");
    return jsonList[0]["is_group"];
  }

  // Get expenses for a board in ascending format by date
  Future<List<Expense>> getExpensesForBoard(String boardId) async {
    List<dynamic> response = await supabase
        .from('expenses')
        .select()
        .eq('board_id', boardId)
        .order('date', ascending: true);

    List<Expense> expenses = [];
    if (response.isEmpty) {
      logger.w("No expenses in board with id $boardId fetched");
    } else {
      logger.d("Fetched expenses for board with id $boardId");
    }
    for (var expenseJson in response) {
      var e = Expense.fromJson(expenseJson);
      e.setId(expenseJson["id"]);
      expenses.add(e);
    }

    return expenses;
  }

// Gets expenses with user provided filters / inverted filters.
  Future<List<Expense>> getExpensesWithFilter(List<String> userIDs,
      List<String> categories, String startDate, String endDate, String boardId,
      {bool invertIds = false,
      bool invertCategories = false,
      bool invertDates = false}) async {
    List<Expense> expenses = [];
    bool filteringDates = startDate.isNotEmpty && endDate.isNotEmpty;
    // build out the query
    var query = supabase.from("expenses").select().eq("board_id", boardId);

    // apply IDs filter
    if (userIDs.isNotEmpty) {
      logger.d("Filtering expenses by creator IDs provided");
      query = invertIds
          ? query.not("creator_id", "in", userIDs)
          : query.filter("creator_id", "in", userIDs);
    }

    // apply categories filter
    if (categories.isNotEmpty) {
      logger.d("Filtering expenses by categories provided");
      query = invertCategories
          ? query.not("category", "in", categories)
          : query.filter("category", "in", categories);
    }

    // to handle date filtering without inversion is simple
    // if user wants to invert results, we will just run the query as is
    // with no date specifified, then remove the results that match the dates
    // we don't want

    // date range
    if (filteringDates && startDate != endDate) {
      logger.d("Filtering expenses by date span : $startDate - $endDate");
      if (!invertDates) {
        // if we are not inverting the dates, we just leave the query as is
        // and after getting results, we remove any that match the date / span
        query = query.gte("date", startDate).lte("date", endDate);
      }
    }
    // single date
    else if (filteringDates) {
      // we simply search for that date
      logger.d("Filterng expenses by specific date: $startDate");
      if (!invertDates) {
        query = query.eq("date", startDate);
      }
    }

    // at this stage, we have applied all neccessary filters. The only thing we
    // must account for is inverted dates.
    var expenseJsonList = await query.order('date', ascending: true);
    logger.d("Converting filtered results to expense objects");
    if (filteringDates) {
      if (!invertDates) {
        for (var json in expenseJsonList) {
          var e = Expense.fromJson(json);
          e.setId(json["id"]);
          expenses.add(e);
        }
      } else {
        for (var json in expenseJsonList) {
          // remove a single date
          if (startDate == endDate) {
            if (DateTime.parse(json["date"])
                .isAtSameMomentAs(DateTime.parse(startDate))) continue;
            var e = Expense.fromJson(json);
            e.setId(json["id"]);
            expenses.add(e);
          }
          // remove a span of dates - only add to expenses if date < start date
          // or if date > end date
          else {
            if (DateTime.parse(json["date"])
                    .isBefore(DateTime.parse(startDate)) ||
                DateTime.parse(json["date"]).isAfter(DateTime.parse(endDate))) {
              var e = Expense.fromJson(json);
              e.setId(json["id"]);
              expenses.add(e);
            }
          }
        }
      }
    } else {
      // if not filtering dates
      for (var json in expenseJsonList) {
        var e = Expense.fromJson(json);
        e.setId(json["id"]);
        expenses.add(e);
      }
    }
    logger
        .d("Fetched expense objects matching user's filter for board $boardId");
    return expenses;
  }

  Future<Expense> getExpense(String expenseId) async {
    final expenseExists =
        await supabase.from('expenses').select().eq('id', expenseId);

    if (expenseExists != null) {
      logger.d("Found expense with id $expenseId");
      List<dynamic> expenseJson =
          await supabase.from('expenses').select().eq('id', expenseId);

      Map<String, dynamic> json = expenseJson.first;
      var expense = Expense.fromJson(json);
      expense.id = json['id'];

      return expense;
    }

    logger.e("Expense with id $expenseId doesn't exist");
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
      logger.e("Error updating expense board with id $expenseId");
    }

    return updatedExpense;
  }

  Future<bool> uploadReceiptUrl(int expenseId, String? addedReceiptUrl) async {
    if (addedReceiptUrl == null) return false;
    var updatedExpense = await supabase
        .from("expenses")
        .update({"receipt_image_url": addedReceiptUrl})
        .eq("id", expenseId)
        .select() as List;

    if (!(updatedExpense.first["receipt_image_url"] == addedReceiptUrl)) {
      await supabase.storage.from("receipts").remove([addedReceiptUrl]);
      logger
          .e("Failed to upload receipt URL to database - removed from storage");
      return false;
    }
    return true;
  }

  Future<String> generateSignedReceiptUrl(int expenseId) async {
    var json = await supabase
        .from("expenses")
        .select("receipt_image_url")
        .eq("id", expenseId) as List;

    if (json.isEmpty) {
      logger.e(
          "Failed to get expense receipt $expenseId URL or no such expense exists.");
    }

    var receiptUrl = json.first["receipt_image_url"];
    if (receiptUrl == null) {
      logger.e("Failed to fetch image URL");
      return "";
    }
    var uri = Uri.parse(receiptUrl);
    String fileName = uri.pathSegments.last;

    // generate signed URL
    var signedUrlResponse =
        await supabase.storage.from("receipts").createSignedUrl(fileName, 90);
    if (signedUrlResponse.isEmpty) {
      logger.e("Failed to generate signed URL for receipt $expenseId");
    } else {
      logger.d("Signed receipt URL for receipt $expenseId has been generated");
    }

    return signedUrlResponse;
  }

  Future<bool> hasReceipt(int expenseId) async {
    var json = await supabase
        .from("expenses")
        .select("receipt_image_url")
        .eq("id", expenseId) as List;

    return json.first["receipt_image_url"] != null;
  }

  Future<bool> deleteReceipt(int expenseId) async {
    // Retrieve the receipt URL from your database.
    var json = await supabase
        .from("expenses")
        .select("receipt_image_url")
        .eq("id", expenseId) as List;

    if (json.isEmpty) {
      logger.e(
          "Failed to get expense receipt $expenseId URL or no such expense exists.");
      return false;
    }

    var receiptUrl = json.first["receipt_image_url"];
    var uri = Uri.parse(receiptUrl);

    // We assume that the path segment immediately following 'object' in the URL
    // path is the bucket name, 'receipts'.
    // Then the rest is the path within the bucket.
    logger.d("Fetching receipt URL path to delete from storage");
    List<String> pathSegments = uri.pathSegments;
    int objectIndex = pathSegments.indexOf('object');
    String key = pathSegments
        .sublist(objectIndex + 2)
        .join('/'); // Skip 'object' and the bucket name

    // Now we should have the correct path to use with remove.
    final deleteResponse =
        await supabase.storage.from('receipts').remove([key]);
    if (deleteResponse.isEmpty) {
      logger.e('Error deleting receipt for expense $expenseId');
      return false;
    } else {
      // Update the expenses table to remove the receipt URL.
      var result = await supabase
          .from('expenses')
          .update({'receipt_image_url': null})
          .eq('id', expenseId)
          .select() as List;
      if (result.first["receipt_image_url"] == null) {
        logger.d("Receipt successfully deleted for expense $expenseId");
        return true;
      }
      logger.e(
          "Failed to delete receipt URL for expense $expenseId from expenses table");
      return false;
      // TODO - a clean up method called when expenses are fetched that, if there isn't a file at the url, automatically updates it to null
    }
    // TODO - error handling, try catch etc
  }

// Add expenses to a board
  Future<Expense> addExpense(Map<String, dynamic> expenseData) async {
    var added = await supabase.from('expenses').insert([expenseData]).select();

    if (added == null) {
      // Handle error
      logger.e('Error adding expense from provided data: $expenseData');
      return Expense.blank();
    }
    var insertedExpenseData = added as List<dynamic>;
    var id = insertedExpenseData.first['id'];
    var e = Expense.fromJson(expenseData);
    e.setId(id);
    logger.d(
        "Added expense with $id to board with id ${expenseData["board_id"]}");
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
      logger.e("Failed to delete expense with id $expenseId");
      return null;
    }

    logger.d("Deleted expense with id $expenseId");
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
      logger.d("Invite email sent to $email");
    } catch (e) {
      logger.e(e);
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

    if (stored == null) {
      logger.e("Failed to store invite details for invite $token");
      return false;
    }
    logger.d("Invite $token stored");
    return true;
  }

  Future<Invitation?> getInvite(String token) async {
    List<dynamic> inviteData =
        await supabase.from("invitations").select().eq("token", token);
    if (inviteData.isNotEmpty) {
      logger.d("Fetched invite $token");
      return Invitation.fromJson(inviteData.first);
    }
    logger.e("Failed to fetch invite with token $token");
    return null;
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
        logger.e("Error updating status of token");
        return null;
      }

      var invitation = Invitation.fromJson(updatedJson);
      bool added = await addMemberToBoard(invitation);
      if (added) {
        logger.d("Successfully accepted invite token $token");
        return Invitation.fromJson(updatedJson);
      }

      // if not added, then change status back and return null
      updatedJson["status"] = "sent";
      logger.e("Failed to add user to board - invite status remains unchanged");
      await supabase
          .from("invitations")
          .update(updatedJson)
          .match({'token': token});
      return null;
    } else {
      logger.e("Failed to fetch invite data for token $token");
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
        logger.e("Error updating status of token");
        return null;
      }
      logger.d("Declined invite for token $token");
      return Invitation.fromJson(updatedJson);
    } else {
      logger.e("Failed to fetch invite data for token $token");
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
        logger.e("Failed to add owner for new board");
        return !added;
      }
      added = true;
    } catch (e) {
      //TOOD - handle exception
      logger.e("Failed to add owner for board $boardId");
      return !added;
    }
    logger.d("Assigned user $userId as creator of $boardId");
    return added;
  }

  // Add a new user to a group expense board
  Future<bool> addMemberToBoard(Invitation invitation) async {
    bool added = true;

    try {
      final Map<String, dynamic> groupMemberJson = {
        "board_id": invitation.boardId,
        "user_id": invitation.invitedId,
        "role": invitation.role.toString().split(".").last,
        "user_email": invitation.invitedEmail
      };
      final resp =
          await supabase.from("group_members").insert(groupMemberJson).select();

      if (resp == null) {
        logger.e(
            "Failed to add member ${invitation.invitedEmail} to board ${invitation.boardId}");
        return !added;
      }

      logger.d(
          "Added member ${invitation.invitedEmail} to board ${invitation.boardId}");
      return added;
    } catch (e) {
      logger.e("Error: $e\nFailed to add member to board");
    }

    logger.e(
        "Encountered an unknown error while attemtping to add ${invitation.invitedEmail} to board from invite ${invitation.token}");
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
    logger.i("Fetching invites for $email");
    return invites;
  }

// Get list of group members for an expense bard
  Future<List<GroupMember>> getGroupMembers(
      String boardId, bool isAdmin) async {
    List<GroupMember> members = [];

// if owner, view ALL but your own
    if (!isAdmin) {
      logger.d("Fetching all group mmebers for board with id $boardId");
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
      logger.d("Fetching shareholder members for board with id $boardId");
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

    if (members.isEmpty) {
      logger.w("No group members found for board with id $boardId");
    } else {
      logger.d("Successfully fetched members for board with id $boardId");
    }

    members.isEmpty
        ? logger.w("No group members found for board with id $boardId")
        : logger.d("Successfully fetched members for board with id $boardId");
    return members;
  }

// Remove a group member from a board using their email address
  Future<bool> removeGroupMember(String boardId, String email) async {
    final resp = await supabase
        .from("group_members")
        .delete()
        .match({"board_id": boardId, "user_email": email});

    if (resp != null) {
      logger.e("Failed to remove $email from board with id $boardId");
    } else {
      logger.d("Removed $email from board with id $boardId");
    }
    return resp == null;
  }

  Future<bool> updateBoardName(String boardId, String newName) async {
    final resp =
        await supabase.from("expense_boards").select().eq("id", boardId);

    if (resp == null) {
      logger.e("Failed to update board name for board with id $boardId");
      return false;
    }

    if (resp is List<dynamic>) {
      resp.first["name"] = newName;
      updateExpenseBoard(boardId, resp.first);
    }
    logger.d("Updated board name for board with id $boardId to $newName");
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
      logger.e(
          "NOT PERMITTED - Current user is not the owner of board with id $boardId");
      return !transferred;
    }

    var newOwner = (await supabase
            .from("group_members")
            .select()
            .eq("board_id", boardId)
            .eq("user_email", email) as List<dynamic>)
        .firstOrNull;

    if (newOwner == null || newOwner.isEmpty) {
      logger.e("Failed to find member with $email for ownership transfer");
      return !transferred;
    }

    // 2 - Add current user as an Admin in Group Members
    final changedToAdmin = await supabase
        .from("group_members")
        .update({"role": "admin"}).match(
            {"board_id": boardId, "user_id": userId}).select();

    // 3 - Change other user to Owner in in Group Members
    final changedToOwner = await supabase
        .from("group_members")
        .update({"role": "owner"}).match(
            {"board_id": boardId, "user_email": email}).select();

    if (changedToAdmin == null || changedToOwner == null) {
      // error handling
      logger.e(
          "Failed to perform ownership transfer to $email for board with id $boardId");
      return !transferred;
    }

    logger.d("$email assigned as new owner of board with id $boardId");
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
      logger.e("Failed to fetch role in board $boardId for $email");
      return "";
      //TODO - proper error handling
    }

    logger.d("Fetched current user's role for board with id $boardId");
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
      logger.e("Failed to get members for board $boardId");
      return [];
    }

    logger.d("Fetched member emails for board with id $boardId");
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
      logger.e("Failed to fetch categories for board $boardId");
      return List.empty();
    }

    logger.d("Fetched categories for board with id $boardId");
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
      logger.e("Failed to fetch member records for board $boardId");
      return List.empty();
    }

    logger.d("Fetched member records for board with id $boardId");
    // specifified output of map for clarity - (userId, userEmail) records
    return allMemberRecords.map<(String userId, String userEmail)>((json) {
      return (json['user_id'] as String, json['user_email'] as String);
    }).toList();
  }
}
