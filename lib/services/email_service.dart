import 'package:expensee/enums/roles.dart';
import 'package:expensee/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:logger/logger.dart";
import 'package:uuid/uuid.dart';

var logger = Logger();

class EmailService {
  final _endpointUrl =
      "https://piqrlsincgavakepwelg.supabase.co/functions/v1/send-email";

  Future<void> sendEmail(String to, String subject, String html) async {
    final url = Uri.parse(_endpointUrl);
    final jwtToken = supabase.auth.currentSession!.accessToken;

    final emailResp = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode({
          "to": to,
          "subject": subject,
          "text": 'THIS IS NO LONGER HTML!' // html
        }));
    if (emailResp.statusCode == 200) {
      logger.i("Email '$subject' sent successfully to $to");
    } else {
      logger.e("Email '$subject' failed to sent to $to");
    }
  }

  String inviteText(String url) =>
      "You've been invited to an expense board! Click here to join:\n$url";

// TODO - validate board id exists
// TODO - reformat email to include board name, inviter email, and role given
  Future<void> sendInviteEmail(String email, String boardId, Roles role) async {
    final url = Uri.parse(_endpointUrl);
    final jwtToken = supabase.auth.currentSession!.accessToken;

    String emailBody = '''
      <html>
      <body>
        <p>You've been invited to an expense board! This can be managed in the app.</p>
      </body>
      </html>
      ''';

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
  }
}
