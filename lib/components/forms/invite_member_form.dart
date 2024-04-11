import 'package:expensee/components/dialogs/default_success_dialog.dart';
import 'package:expensee/components/dropdown/roles_dropdown.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/enums/roles.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart' as Provider;

class InviteUserForm extends StatefulWidget {
  const InviteUserForm({super.key, required this.boardId, required this.role});
  final String boardId;
  final String role;

  @override
  State<StatefulWidget> createState() => _InviteUserFormState();
}

class _InviteUserFormState extends State<InviteUserForm> {
  final _formKey = GlobalKey<FormState>(); // unique id
  Roles _selectedRole = Roles.shareholder;

  // to store user input
  String _userEmail = "";

  // handle form submission
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // save current state of the form

      var gMemberProvider =
          Provider.Provider.of<GroupMemberProvider>(context, listen: false);

      // Send mock email
      await gMemberProvider.sendInvite(
          _userEmail, widget.boardId, _selectedRole);

      // Build context may have been removed from widget tree by the time async method
      // finishes. We check if its mounted before trying to use it to prevent a crash.
      if (!mounted) return; // TODO - error alert

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DefaultSuccessDialog(
                successMessage: inviteSentText(_userEmail));
          });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.Provider.of<BoardProvider>(context, listen: false)
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
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: addUserText),
              onSaved: (value) => _userEmail = value!,
              validator: (value) => value!.isEmpty ? insertEmailText : null,
            ),
            if (isOwner)
              RolesDropdownMenu(
                onRoleChanged: (Roles newRole) => _selectedRole = newRole,
              ), // Use conditional if isOwner
            ElevatedButton(onPressed: _submit, child: sendInviteText)
          ],
        ),
      ),
    );
  }
}
