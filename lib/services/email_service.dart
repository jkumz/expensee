import 'dart:convert';

import 'package:expensee/enums/roles.dart';
import 'package:expensee/main.dart';
import 'package:http/http.dart' as http;
import "package:logger/logger.dart";

var logger = Logger();

class EmailService {
  final _endpointUrl =
      "https://piqrlsincgavakepwelg.supabase.co/functions/v1/send-email";

// Sends email notifying recipient list of user's email who got removed from board
  Future<bool> sendRemovedUserEmail(
      List<String> recipientList, String removedEmail, String boardName) async {
    try {
      final url = Uri.parse(_endpointUrl);
      final jwtToken = supabase.auth.currentSession!.accessToken;

      String subject = "$boardName - User Removed";
      String body =
          "User with the email $removedEmail has been removed from board $boardName";

      final emailResp = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken'
          },
          body: jsonEncode(
              {"to": recipientList, "subject": subject, "text": body}));
      if (emailResp.statusCode == 200) {
        logger.i("Email '$subject' sent successfully to $recipientList");
        return true;
      } else {
        logger.e("Email '$subject' failed to sent to $recipientList");
        return false;
      }
    } catch (e) {
      logger.e(
          "Failed to send email notifying about removal of $removedEmail from $boardName");
      logger.e("$e");
    }
    return false;
  }

// Sends email notifying recipient list of user's email who got added to board
  Future<bool> sendAddedUserEmail(
      List<String> recipientList, String addedEmail, String boardName) async {
    try {
      final url = Uri.parse(_endpointUrl);
      final jwtToken = supabase.auth.currentSession!.accessToken;

      String subject = "$boardName - User Added";
      String body =
          "User with the email $addedEmail has been added to the board $boardName";

      final emailResp = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken'
          },
          body: jsonEncode(
              {"to": recipientList, "subject": subject, "textCenter": body}));
      if (emailResp.statusCode == 200) {
        logger.i("Email '$subject' sent successfully to $recipientList");
        return true;
      } else {
        logger.e("Email '$subject' failed to sent to $recipientList");
        return false;
      }
    } catch (e) {
      logger.e(
          "Failed to send email notifying about addition of $addedEmail to $boardName");
      logger.e("$e");
    }
    return false;
  }

  Future<bool> sendEmailNotification(
      List<String> recipientList, String subject, String body) async {
    try {
      final url = Uri.parse(_endpointUrl);
      final jwtToken = supabase.auth.currentSession!.accessToken;

      final emailResp = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken'
          },
          body: jsonEncode(
              {"to": recipientList, "subject": subject, "text": body}));
      if (emailResp.statusCode == 200) {
        logger.i("Email '$subject' sent successfully to $recipientList");
        return true;
      } else {
        logger.e("Email '$subject' failed to sent to $recipientList");
        return false;
      }
    } catch (e) {
      logger.e("Failed to send emails to list of recipients");
      logger.e("$e");
    }
    return false;
  }

  String inviteText(String url) =>
      "You've been invited to an expense board! Click here to join:\n$url";

// TODO - validate board id exists, despite only being possible to access from a boards invite form
// TODO - reformat email to include board name, inviter email, and role given
  Future<void> sendInviteEmail(String email, String boardId, Roles role) async {
    try {
      final url = Uri.parse(_endpointUrl);
      final jwtToken = supabase.auth.currentSession!.accessToken;

      String emailBody =
          "Hi $email,\n\nYou've been invited to an expense board as '${role.toFormattedString()}', respond in the app!\n\n-The Expensee Team";

      final int? boardIdInt = int.tryParse(boardId);
      if (boardIdInt == null) {
        logger.e("Error: $boardId is not a valid integer");
        return;
      }

      final emailResponse = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
          body: jsonEncode({
            'to': [email],
            'subject': "Board Invitation",
            'text': emailBody,
          }));
      if (emailResponse.statusCode == 200) {
        logger.i("Email sent successfuly");
      } else {
        logger.e("Email failed to send");
      }
    } catch (e) {
      logger.e(
          "Failed to send email notifying $email about their invite to board with ID $boardId");
      logger.e("$e");
    }
  }
}
