// ignore_for_file: use_build_context_synchronously

import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/components/dialogs/default_success_dialog.dart';
import 'package:expensee/components/dropdown/user_dropdown.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

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
          content: noEmailText,
        ));
        return;
      }

      var gMemberProvider =
          Provider.of<GroupMemberProvider>(context, listen: false);

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
      await Provider.of<GroupMemberProvider>(context, listen: false)
          .notifyUserRemoval(widget.boardId, selectedEmail);

      showDialog(
          context: context,
          builder: (BuildContext c) {
            return DefaultSuccessDialog(
                successMessage:
                    "$selectedEmail has been removed from the expense board");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(), // Call the combined data fetching method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error case
        } else {
          bool isAdmin = snapshot.data?['isAdmin'] ?? false;
          List members = snapshot.data?['members'] ?? [];

          if (members.isEmpty) {
            return noMembers;
          } else {
            return _buildForm(context, isAdmin, members);
          }
        }
      },
    );
  }

  Widget _buildForm(BuildContext context, bool isAdmin, List members) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                selectUserText,
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
            ElevatedButton(
                onPressed: _submit, child: const Text(removeUserText))
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final isAdmin = await Provider.of<BoardProvider>(context, listen: false)
        .checkIfAdmin(widget.boardId);
    final members =
        await Provider.of<GroupMemberProvider>(context, listen: false)
            .getGroupMembers(widget.boardId, false);

    return {
      'isAdmin': isAdmin,
      'members': members,
    };
  }
}
