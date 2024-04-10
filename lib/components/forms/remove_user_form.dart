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

      if (selectedEmail == "@") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("You must select an email to remove."),
        ));
        return;
      }

      var gMemberProvider =
          Provider.Provider.of<GroupMemberProvider>(context, listen: false);

      // Send mock email
      bool removed = await gMemberProvider.removeGroupMember(
          widget.boardId, selectedEmail);
      // Build context may have been removed from widget tree by the time async method
      // finishes. We check if its mounted before trying to use it to prevent a crash.
      if (!mounted) return;
      if (!removed) {
        DefaultErrorDialog(
            errorMessage: "Failed to remove $selectedEmail from the board");
        return;
      }
      await Provider.Provider.of<GroupMemberProvider>(context, listen: false)
          .notifyUserRemoval(widget.boardId, selectedEmail);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$selectedEmail has been removed from the expense board"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchData(), // Call the combined data fetching method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error case
        } else {
          // Now you have both isAdmin and members data
          bool isAdmin = snapshot.data?['isAdmin'] ?? false;
          List members = snapshot.data?['members'] ?? [];

          if (members.isEmpty) {
            return const Center(
              child: Text("No members to remove"), // Show message if no members
            );
          } else {
            return buildForm(context, isAdmin,
                members); // Pass both isAdmin and members to the form
          }
        }
      },
    );
  }

// TODO - text styling, consts moved to const file
  Widget buildForm(BuildContext context, bool isAdmin, List members) {
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

  Future<Map<String, dynamic>> fetchData() async {
    final isAdmin =
        await Provider.Provider.of<BoardProvider>(context, listen: false)
            .checkIfAdmin(widget.boardId);
    final members =
        await Provider.Provider.of<GroupMemberProvider>(context, listen: false)
            .getGroupMembers(widget.boardId, false);

    return {
      'isAdmin': isAdmin,
      'members': members,
    };
  }
}
