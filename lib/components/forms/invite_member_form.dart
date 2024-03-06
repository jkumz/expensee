import 'package:expensee/providers/g_member_provider.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart' as Provider;

class InviteUserForm extends StatefulWidget {
  const InviteUserForm({super.key});

  @override
  State<StatefulWidget> createState() => _InviteUserFormState();
}

class _InviteUserFormState extends State<InviteUserForm> {
  final _formKey = GlobalKey<FormState>(); // unique id

  // to store user input
  String _userEmail = "";

  // handle form submission
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // save current state of the form

      var gMemberProvider =
          Provider.Provider.of<GroupMemberProvider>(context, listen: false);

      // Send mock email
      await gMemberProvider.sendInvite(_userEmail, "TEST", "test email");

      // Build context may have been removed from widget tree by the time async method
      // finishes. We check if its mounted before trying to use it to prevent a crash.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invite sent to $_userEmail"),
      ));

      // ConditionalSnackbar.show(context,
      //     isSuccess: created,
      //     message: boardCreationSuccessMessage,
      //     errMsg: boardCreationFailureMessage);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Invite User"),
              // assign name input
              onSaved: (value) => _userEmail = value!,
              // validate name input
              validator: (value) =>
                  value!.isEmpty ? "Please enter an email address" : null,
            ),
            ElevatedButton(onPressed: _submit, child: const Text("Sned invite"))
          ],
        ),
      ),
    );
  }
}
