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
  Future<void> sendInvite(String email, String boardId) async {
    final url = Uri.parse(_endpointUrl);
    final jwtToken = supabase.auth.currentSession!.accessToken;
    final inviteCallback = '${dotenv.env['PROJECT_SCHEMA']}://invite/';
    final inviteLink = inviteText(inviteCallback);

    String emailBody = '''
      <html>
      <body>
        <p>Click the link below to access your board:</p>
        <p><a href="$inviteLink">Access Board</a></p>
      </body>
      </html>
      ''';

    // Generate invitation token
    const uuid = Uuid();
    final invitationToken = uuid.v4();
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
      // Store token in supabase
      await supabase.from('invitations').insert({
        'board_id': boardIdInt,
        'invitee_email': email,
        'token': invitationToken,
        'status': 'sent',
        'inviter_id': supabase.auth.currentUser!.id
      });
    } else {
      logger.e("Email failed to send");
    }
  }
}
