import 'package:expensee/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:logger/logger.dart";
import 'package:uuid/uuid.dart';

var logger = Logger();

class EmailService {
  Future<void> sendInvite(String email, String boardId) async {
    final url = Uri.parse("https://api.resend.com/emails");
    final apiKey = dotenv.env["RESEND_API_KEY"];

    // Generate invitation token
    const uuid = Uuid();
    final invitationToken = uuid.v4();
    final int? boardIdInt = int.tryParse(boardId);
    if (boardIdInt == null) {
      logger.e("Error: $boardId is not a valid integer");
      return;
    }

    // Store token in supabase
    final resp = await supabase.from('invitations').insert({
      'board_id': boardIdInt,
      'invitee_email': email,
      'token': invitationToken,
      'status': 'sent',
      'inviter_id': supabase.auth.currentUser!.id
    });

    final emailResponse = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'from': 'onboarding@resend.dev',
          'to': [email],
          'subject': 'hello world',
          'html': '<strong>it works!</strong>',
        }));
    if (emailResponse.statusCode == 200) {
      logger.i("Email sent successfuly");
    } else {
      logger.e("Email failed to send");
    }
  }
}
