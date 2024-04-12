// ignore_for_file: use_build_context_synchronously

import 'package:expensee/components/dropdown/user_dropdown.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:expensee/util/dialog_helper.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class TransferOwnershipForm extends StatefulWidget {
  const TransferOwnershipForm(
      {super.key, required this.boardId, required this.role});
  final String boardId;
  final String role;

  @override
  State<StatefulWidget> createState() => _TransferOwnershipFormState();
}

class _TransferOwnershipFormState extends State<TransferOwnershipForm> {
  final _formKey = GlobalKey<FormState>(); // unique id
  String selectedEmail = "@";

  // handle form submission
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // save current state of the form

      var gMemberProvider =
          Provider.of<GroupMemberProvider>(context, listen: false);

      // Before transferring ownership, we get the user to confirm their decision.
      bool confirmed = await DialogHelper.showConfirmationDialog(
          context,
          "Are you sure you wish to transfer your owner ship of this expense board to $selectedEmail?" +
              "\n\nOnce you do this, the only way to get your ownership back is if the other user gives it back!");
      if (confirmed) {
        bool removed = await gMemberProvider.transferOwnership(
            widget.boardId, selectedEmail);
        // Build context may have been removed from widget tree by the time async method
        // finishes. We check if its mounted before trying to use it to prevent a crash.
        if (!mounted) return;
        if (!removed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to remove $selectedEmail from the board"),
          ));
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$selectedEmail has been granted ownership!"),
        ));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ownership transfer cancelled!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.of<BoardProvider>(context, listen: false)
          .checkIfOwner(widget.boardId),
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

  Widget buildForm(BuildContext context, bool isOwner) {
    if (!isOwner) {
      return Form(
        key: _formKey,
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              Center(
                child: Center(
                  child: unAuthorizedAccessText,
                ),
              )
            ],
          ),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Center(child: selectOwnerText),
            UserDropdownMenu(
              onUserSelected: (String user) => selectedEmail = user,
              isAdmin: !isOwner,
              boardId: widget.boardId,
            ), // Use conditional if isOwner
            ElevatedButton(onPressed: _submit, child: transferOwnershipText)
          ],
        ),
      ),
    );
  }
}
