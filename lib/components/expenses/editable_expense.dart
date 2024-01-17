import 'package:expensee/components/expenses/base_expense.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';

// TODO - More rendering / options for group expenses
class ExpenseCreationForm extends BaseExpenseItem {
  final Expense expense;

  const ExpenseCreationForm({super.key, required this.expense})
      : super(expense: expense);

  @override
  createState() => _ExpenseCreationFormState();
}

class _ExpenseCreationFormState extends State<ExpenseCreationForm> {
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  final repo = ExpenseRepository();

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.expense.category);
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _amountController =
        TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _dateController =
        TextEditingController(text: widget.expense.date.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
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
              controller: _categoryController,
              readOnly: false,
              decoration: const InputDecoration(
                  labelText: editableExpenseCategoryLabelText),
              onSubmitted: (value) {
                _updateCategory(value);
              },
            ),
            TextField(
              controller: _descriptionController,
              readOnly: false,
              decoration: const InputDecoration(
                  labelText: editableDescriptionLabelText),
              onSubmitted: (value) {
                print("test");
                _updateDescription(value);
              },
              onTap: () => print("test tap"),
            ),
            TextField(
              controller: _amountController,
              decoration:
                  const InputDecoration(labelText: editableAmountLabelText),
              readOnly: false,
              onSubmitted: (value) async {
                final amount = double.tryParse(value);
                if (amount == null) {
                  // TODO - handle no input - show toast
                } else {
                  var updated = await _updateAmount(amount);
                  if (updated.amount == amount) {
                    setState(() {
                      widget.expense.amount = amount;
                    });
                  }
                }
              },
            ),
            TextField(
              controller: _dateController,
              decoration:
                  const InputDecoration(labelText: editableDateLabelText),
              readOnly: false,
              onTap: () => {_selectDate(context)},
              onSubmitted: (date) async {
                final updatedDate = DateTime.tryParse(date);
                if (updatedDate == null) {
                  // TODO - handle null date
                } else {
                  var updated = await _updateDate(updatedDate);
                  if (updated.date == updatedDate) {
                    setState(() {
                      widget.expense.date = updatedDate;
                    });
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }

// Method for updating category based on user input
  Future<Expense> _updateCategory(String category) async {
    var json = widget.expense.toJson();
    json["category"] = category;

    return await repo.updateExpense("${widget.expense.id}", json);
  }

// Method for updating description based on user input
  Future<Expense> _updateDescription(String description) async {
    var json = widget.expense.toJson();
    json["description"] = description;

    return await repo.updateExpense("${widget.expense.id}", json);
  }

// Method for updating amount based on user input
  Future<Expense> _updateAmount(double amount) async {
    var json = widget.expense.toJson();
    json["amount"] = amount;
    return await repo.updateExpense("${widget.expense.id}", json);
  }

  // Pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2008),
        lastDate: DateTime.now(),
        initialDate: widget.expense.date ?? DateTime.now());

    // if new date, update it in the UI
    if (pickedDate != null && pickedDate != widget.expense.date) {
      setState(() {
        _dateController.text = expenseDateToString(pickedDate);
      });
    }
  }

  Future<Expense> _updateDate(DateTime date) async {
    var json = widget.expense.toJson();
    json["date"] = date;
    return await repo.updateExpense("${widget.expense.id}", json);
  }
}
