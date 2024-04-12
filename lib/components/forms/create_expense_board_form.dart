import 'package:expensee/config/constants.dart';
import 'package:expensee/providers/board_provider.dart';
import "package:flutter/material.dart";
import "package:expensee/components/snackbars/conditional_snackbar.dart";
import 'package:provider/provider.dart';

class CreateExpenseBoardForm extends StatefulWidget {
  const CreateExpenseBoardForm({super.key});

  @override
  State<StatefulWidget> createState() => _CreateExpenseBoardFormState();
}

class _CreateExpenseBoardFormState extends State<CreateExpenseBoardForm> {
  final _formKey = GlobalKey<FormState>(); // unique id

  // to store user input
  String _boardName = "";
  bool _isGroup = false;
  String _balance = "";

  // handle form submission
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // save current state of the form

      var boardProvider = Provider.of<BoardProvider>(context, listen: false);

      // Use service layer to create an expense board
      bool created = await boardProvider.createBoard({
        'name': _boardName,
        'is_group': _isGroup,
        'balance': double.parse(_balance),
        'initial_balance': double.parse(_balance)
      });

      // Build context may have been removed from widget tree by the time async method
      // finishes. We check if its mounted before trying to use it to prevent a crash.
      if (!mounted) return;

      ConditionalSnackbar.show(context,
          isSuccess: created,
          message: boardCreationSuccessMessage,
          errMsg: boardCreationFailureMessage);

      if (created) {
        Navigator.pop(context);
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
              decoration: const InputDecoration(labelText: "Board Name"),
              // assign name input
              onSaved: (value) => _boardName = value!,
              // validate name input
              validator: (value) => value!.isEmpty ? enterBoardName : null,
            ),
            TextFormField(
                decoration:
                    const InputDecoration(labelText: "Starting Balance (GBP)"),
                // assign name input
                onSaved: (value) => _balance = value!,
                // validate name input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return blankValueText;
                  } else if (!RegExp(r'^\d+(\.\d{2})?$').hasMatch(value)) {
                    return invalidValueText;
                  }
                  return null;
                }),
            SwitchListTile(
                title: groupBoardQuestionText,
                value: _isGroup,
                onChanged: (bool val) =>
                    mounted ? setState(() => _isGroup = val) : null),
            ElevatedButton(onPressed: _submit, child: createBoardText)
          ],
        ),
      ),
    );
  }
}
