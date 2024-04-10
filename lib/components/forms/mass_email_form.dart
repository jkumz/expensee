import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO - More rendering / options for group expenses
class MassEmailForm extends StatefulWidget {
  String boardId;

  MassEmailForm({super.key, required this.boardId});

  @override
  createState() => _MassEmailFormState();
}

class _MassEmailFormState extends State<MassEmailForm> {
  late TextEditingController subjectController;
  late TextEditingController bodyController;

  final repo = ExpenseRepository();
  bool isSubmitted = false;
  bool isNameValid = true;
  bool adminOnlyEmail = false;

  @override
  void initState() {
    super.initState();
    subjectController = TextEditingController(text: "Enter email subject");
    bodyController = TextEditingController(text: "Enter email body");

    // TODO - validation
    // subjectController.addListener(() => _validateForm());
    // subjectController.addListener(() => _validateForm());
  }

  void _showFailAlert(bool adminOnly) {
    String message = adminOnly
        ? "Your emails have failed to send to the admin mailing list"
        : "Your emails failed to send to everyone in this board.";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DefaultErrorDialog(title: "Success", errorMessage: message);
      },
    );
  }

  void _showEmptyMailingListError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DefaultErrorDialog(
            title: "Empty Mailing List",
            errorMessage: "Failed to retrieve emails...");
      },
    );
  }

  void _showSuccessAlert(bool adminOnly) {
    String message = adminOnly
        ? "Your emails have been sent to the admin mailing list"
        : "Your emails have been sent to everyone in this board.";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DefaultErrorDialog(title: "Success", errorMessage: message);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    subjectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // subject
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: "Email Subject"),
              readOnly: false,
            ),
            const SizedBox(
              height: 10,
            ),
            // body
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                  labelText: "Email body", alignLabelWithHint: true),
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: null,
              readOnly: false,
            ),
            const SizedBox(
              height: 10,
            ),
            CheckboxListTile(
              title: const Text("Send to Admins Only"),
              value: adminOnlyEmail,
              onChanged: (bool? newValue) {
                if (mounted) {
                  setState(() {
                    adminOnlyEmail = newValue ?? false;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity
                  .leading, // places the checkbox at the start of the tile
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _sendEmails(
                          subjectController.text, bodyController.text);
                    },
                    child: const Text("Send Email"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmails(String subject, String body) async {
    final mailingList = await Provider.of<BoardProvider>(context, listen: false)
        .getMemberEmails(widget.boardId, adminOnlyEmail);

    if (mailingList.isEmpty) {
      _showEmptyMailingListError();
      return;
    }

    if (await Provider.of<BoardProvider>(context, listen: false)
        .sendMassEmail(subject, body, mailingList)) {
      _showSuccessAlert(adminOnlyEmail);
    } else
      _showFailAlert(adminOnlyEmail);
  }
}
