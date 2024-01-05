import 'package:expensee/config/constants.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';

// TODO - More rendering / options for group expenses
class EditableExpenseItem extends StatefulWidget {
  final Expense expense;

  const EditableExpenseItem({Key? key, required this.expense});

  @override
  createState() => _EditableExpenseItemState();
}

class _EditableExpenseItemState extends State<EditableExpenseItem> {
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  final repo = ExpenseRepository();

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.expense.category);
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _amountController =
        TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration:
                  InputDecoration(labelText: editableExpenseCategoryLabelText),
              onSubmitted: (value) {
                updateCategory(value);
              },
            ),
            TextField(
              controller: _descriptionController,
              decoration:
                  InputDecoration(labelText: editableDescriptionLabelText),
              onSubmitted: (value) {
                updateDescription(value);
              },
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: editableAmountLabelText),
              onSubmitted: (value) async {
                final amount = double.tryParse(value);
                if (amount == null) {
                  // TODO - handle no input - show toast
                } else {
                  if (await updateAmount(amount)) {
                    setState(() {
                      widget.expense.amount = amount;
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

// Method for updating category based on user input
  Future<bool> updateCategory(String category) async {
    var json = widget.expense.toJson();
    json["category"] = category;

    return await repo.updateExpense("${widget.expense.id}", json);
  }

// Method for updating description based on user input
  Future<bool> updateDescription(String description) async {
    var json = widget.expense.toJson();
    json["description"] = description;

    return await repo.updateExpense("${widget.expense.id}", json);
  }

// Method for updating amount based on user input
  Future<bool> updateAmount(double amount) async {
    var json = widget.expense.toJson();
    json["amount"] = amount;
    return await repo.updateExpense("${widget.expense.id}", json);
  }
}
