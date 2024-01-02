import 'package:expensee/services/supabase_service.dart';
import "package:flutter/material.dart";
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateExpenseBoardForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateExpenseBoardFormState();
}

class _CreateExpenseBoardFormState extends State<CreateExpenseBoardForm> {
  final _formKey = GlobalKey<FormState>(); // unique id

  // to store user input
  String _boardName = "";
  bool _isGroup = false;

// handle form submission
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // save current state of the form

      // Use service layer to create an expense board
      bool created = await SupabaseService()
          .createExpenseBoard({'name': _boardName, 'is_group': _isGroup});

      if (created) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Created expense board with name $_boardName")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Error - failed to create expense board with name $_boardName",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
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
              decoration: InputDecoration(labelText: "Board Name"),
              // assign name input
              onSaved: (value) => _boardName = value!,
              // validate name input
              validator: (value) =>
                  value!.isEmpty ? "Please enter a board name" : null,
            ),
            SwitchListTile(
                title: const Text("Group board?"),
                value: _isGroup,
                onChanged: (bool val) => setState(() => _isGroup = val)),
            ElevatedButton(
                onPressed: _submit, child: const Text("Create board"))
          ],
        ),
      ),
    );
  }
}
