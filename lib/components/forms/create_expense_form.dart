import 'package:expensee/components/buttons/expense_board_buttons/add_receipt_button.dart';
import 'package:expensee/components/buttons/expense_board_buttons/save_expense_button.dart';
import 'package:expensee/components/expenses/expense.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/providers/expense_provider.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// TODO - More rendering / options for group expenses
class CreateExpenseForm extends ExpenseItem {
  @override
  final Expense expense;
  final bool exists;
  final VoidCallback onClose;

  CreateExpenseForm(
      {super.key,
      required this.expense,
      required this.exists,
      required this.onClose})
      : super(expense: expense);

  @override
  createState() => _CreateExpenseFormState();
}

class _CreateExpenseFormState extends State<CreateExpenseForm> {
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  final repo = ExpenseRepository();
  bool isSubmitted = false;
  bool _isFormValid = true;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.expense.category);
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _amountController =
        TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _dateController =
        TextEditingController(text: expenseDateToString(widget.expense.date));

    // Add validation to controllers
    _amountController.addListener(() => _validateForm());
    _dateController.addListener(() => _validateForm());
  }

  void _validateForm() {
    // Regex - Check it's start of line, then match digit between 1 to 7 times
    // (up to a millions), then match the decimal, then match exactly 2 digits.
    bool isAmountValid =
        RegExp(r'^\d{1,7}\.\d{2}$').hasMatch(_amountController.text);

    // Regex - Check start of line, then match exactly 4 digits for year, then
    // match exactly 2 digits for MM, then 2 for DD. Match '-' inbetween.
    bool isDateValid =
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_dateController.text);

    if (!isAmountValid) {
      _showValidationMessage("Amount must be to 2 decimal places...");
    }
    if (!isDateValid) {
      _showValidationMessage("Date must be in YYYY-MM-DD format");
    }

    setState(() {
      _isFormValid = isAmountValid && isDateValid;
    });
  }

  void _showValidationMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 1),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
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
              inputFormatters: [
                LengthLimitingTextInputFormatter(categoryLength)
              ],
            ),
            TextField(
              controller: _descriptionController,
              readOnly: false,
              decoration: const InputDecoration(
                  labelText: editableDescriptionLabelText),
              inputFormatters: [
                LengthLimitingTextInputFormatter(expenseDescLength)
              ],
            ),
            TextField(
              controller: _amountController,
              decoration:
                  const InputDecoration(labelText: editableAmountLabelText),
              readOnly: false,
            ),
            TextField(
              controller: _dateController,
              decoration:
                  const InputDecoration(labelText: editableDateLabelText),
              readOnly: false,
              onTap: () => {_selectDate(context)},
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: AddReceiptButton(
                  text: "Add Receipt",
                  onPressed: _addReceipt,
                  height: 60,
                  width: 40,
                  contentAlignment: Alignment.center,
                )),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: SaveExpenseButton(
                  text: "Save",
                  onPressed: _saveExpense,
                  height: 60,
                  width: 40,
                  contentAlignment: Alignment.center,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2008),
        lastDate: DateTime.now(),
        initialDate: widget.expense.date);

    // if new date, update it in the UI
    if (pickedDate != null && pickedDate != widget.expense.date) {
      setState(() {
        _dateController.text = expenseDateToString(pickedDate);
      });
    }
  }

// Method for modifying the JSON of the new expense and updating it in the database.
  Future<Expense> _modifyExpense() async {
    var json = widget.expense.toJson();
    json["category"] = _categoryController.value.text;
    json["description"] = _descriptionController.value.text;
    json["amount"] = _amountController.value.text;
    json["date"] = DateTime.tryParse(_dateController.text);
    if (mounted) {
      return await Provider.of<ExpenseProvider>(context, listen: false)
          .updateExpense(json, widget.expense.id.toString());
    } else {
      return widget.expense;
    }
  }

  Future<void> _saveExpense() async {
    await _modifyExpense();
    widget.onClose();
  }

  void _addReceipt() async {
    // prompt user to take a photo
    // store the photo in supabase storage
    // cache it using CDN
    // add reference to supabase file path url in expenses table
    // separate method for viewing receipt
    if (widget.exists) {
      if (widget.expense.id != null) {
        var addedReceiptUrl =
            await Provider.of<ExpenseProvider>(context, listen: false)
                .addReceipt(context, widget.expense.id!);
        bool addedToExpensesTable =
            await Provider.of<ExpenseProvider>(context, listen: false)
                .uploadReceiptUrl(widget.expense.id!, addedReceiptUrl);
        if (addedToExpensesTable) {
          //TODO - show snackbar to say success
        } else {
          // TODO - show error, db & bucket reversal done in service layer
        }
      }
    }
    // if we are only just creating the expense, and not modifying it
    else {}
  }

  void _viewReceipt() {}

  void _deleteReceipt() {}

  void _exportReceiptToPhone() {}
}
