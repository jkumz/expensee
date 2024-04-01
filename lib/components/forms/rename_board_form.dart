import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO - More rendering / options for group expenses
class RenameBoardForm extends StatefulWidget {
  String boardId;

  RenameBoardForm({super.key, required this.boardId});

  @override
  createState() => _RenameBoardFormState();
}

class _RenameBoardFormState extends State<RenameBoardForm> {
  late TextEditingController _nameController;
  final repo = ExpenseRepository();
  bool isSubmitted = false;
  bool _isNameValid = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Enter new name");

    // Add validation to controllers
    _nameController.addListener(() => _validateForm());
    _nameController.addListener(() => _validateForm());
  }

  void _validateForm() {
    String name = _nameController.text;
    setState(() {
      _isNameValid = name.length <= 30;
    });

    if (!_isNameValid) {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Name must be 30 characters or less.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Dismiss the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      //margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
              readOnly: false,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _renameBoard(_nameController.text);
                    },
                    child: Text("Rename"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _renameBoard(String newName) async {
    bool renamed = await Provider.of<BoardProvider>(context, listen: false)
        .updateBoardName(widget.boardId, newName);

    if (!renamed) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DefaultErrorDialog(
              errorMessage: "Failed to rename board to $newName");
        },
      );
    }

    if (renamed) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully renamed boardd to $newName")));
    }
  }
}
