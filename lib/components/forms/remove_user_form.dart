import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/components/dropdown/user_dropdown.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart' as Provider;

class RemoveUserForm extends StatefulWidget {
  const RemoveUserForm({super.key, required this.boardId, required this.role});
  final String boardId;
  final String role;

  @override
  State<StatefulWidget> createState() => _RemoveUserFormState();
}

class _RemoveUserFormState extends State<RemoveUserForm> {
  final _formKey = GlobalKey<FormState>(); // unique id
  String selectedEmail = "@";

  // handle form submission
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // save current state of the form

      var gMemberProvider =
          Provider.Provider.of<GroupMemberProvider>(context, listen: false);

      // Send mock email
      bool removed = await gMemberProvider.removeGroupMember(
          widget.boardId, selectedEmail);
      // Build context may have been removed from widget tree by the time async method
      // finishes. We check if its mounted before trying to use it to prevent a crash.
      if (!mounted) return;
      if (!removed) {
        DefaultAlertDialog(
            errorMessage: "Failed to remove $selectedEmail from the board");
        return;
      }
      await Provider.Provider.of<GroupMemberProvider>(context, listen: false)
          .notifyUserRemoval(widget.boardId, selectedEmail);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$selectedEmail has been removed from the expense board"),
      ));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.Provider.of<BoardProvider>(context, listen: false)
          .checkIfAdmin(widget.boardId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the future to complete
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle the error case
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data == true) {
          // Build the form with the owner's additional options
          return buildForm(context, true);
        } else {
          // Build the form without the owner's additional options
          return buildForm(context, false);
        }
      },
    );
  }

// TODO - text styling, consts moved to const file
  Widget buildForm(BuildContext context, bool isAdmin) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                "Select a user to remove",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            isAdmin
                ? UserDropdownMenu(
                    onUserSelected: (String user) => selectedEmail = user,
                    isAdmin: isAdmin,
                    boardId: widget.boardId,
                  )
                : UserDropdownMenu(
                    onUserSelected: (String user) => selectedEmail = user,
                    isAdmin: !isAdmin,
                    boardId: widget.boardId,
                  ), // Use conditional if isOwner
            ElevatedButton(onPressed: _submit, child: const Text("Remove user"))
          ],
        ),
      ),
    );
  }
}
