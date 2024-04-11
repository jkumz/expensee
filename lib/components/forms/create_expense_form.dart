import 'package:expensee/components/buttons/expense_board_buttons/add_receipt_button.dart';
import 'package:expensee/components/buttons/expense_board_buttons/delete_receipt_button.dart';
import 'package:expensee/components/buttons/expense_board_buttons/save_expense_button.dart';
import 'package:expensee/components/buttons/expense_board_buttons/view_receipt_button.dart';
import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/components/expenses/expense.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/providers/expense_provider.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// TODO - better validation
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
  bool hasReceipt = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkReceipt();
    });

    // Add validation to controllers
    _amountController.addListener(() => _validateForm());
    _dateController.addListener(() => _validateForm());
  }

  Future<void> _checkReceipt() async {
    hasReceipt = await Provider.of<ExpenseProvider>(context, listen: false)
        .hasReceipt(widget.expense.id!);
  }

// TODO - make this better... --> error shown on submit, rather than every time
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
      _showInvalidValueMessage();
    }
    if (!isDateValid) {
      _showInvalidDateMessage();
    }

    if (mounted) {
      setState(() {
        _isFormValid = isAmountValid && isDateValid;
      });
    }
  }

  void _showInvalidValueMessage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DefaultErrorDialog(errorMessage: invalidValueText);
        });
  }

  void _showInvalidDateMessage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DefaultErrorDialog(errorMessage: invalidDateText);
        });
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
        child: _renderButtons(),
      ),
    );
  }

  Widget _renderButtons() {
    return Column(
      children: [
        TextField(
          controller: _categoryController,
          readOnly: false,
          decoration: const InputDecoration(
              labelText: editableExpenseCategoryLabelText),
          inputFormatters: [LengthLimitingTextInputFormatter(categoryLength)],
        ),
        TextField(
          controller: _descriptionController,
          readOnly: false,
          decoration:
              const InputDecoration(labelText: editableDescriptionLabelText),
          inputFormatters: [
            LengthLimitingTextInputFormatter(expenseDescLength)
          ],
        ),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: editableAmountLabelText),
          readOnly: false,
        ),
        TextField(
          controller: _dateController,
          decoration: const InputDecoration(labelText: editableDateLabelText),
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
              isEnabled: !hasReceipt,
            )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
                child: ViewReceiptButton(
              text: "View Receipt",
              onPressed: _viewReceipt,
              height: 60,
              width: 40,
              contentAlignment: Alignment.center,
              isEnabled: hasReceipt,
            )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
                child: DeleteReceiptButton(
              text: "Delete Receipt",
              onPressed: _deleteReceipt,
              height: 60,
              width: 40,
              contentAlignment: Alignment.center,
              isEnabled: hasReceipt,
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
      if (mounted) {
        setState(() {
          _dateController.text = expenseDateToString(pickedDate);
        });
      }
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
          if (mounted) {
            setState(() {
              hasReceipt = true;
            });
          }
        } else {
          // TODO - show error, db & bucket reversal done in service layer
        }
      }
    }
    // if we are only just creating the expense, and not modifying it
    else {}
  }

  void _viewReceipt() async {
    Image img = await Provider.of<ExpenseProvider>(context, listen: false)
        .getReceiptForExpense(widget.expense.id!);

    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double
                        .infinity, // Ensures the container fills the width
                    child: img,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await _saveReceiptToCameraRoll();
                        Navigator.of(context).pop(); // Save functionality
                      },
                      child: saveText,
                    ),
                    TextButton(
                      onPressed: () async {
                        // Delete functionality with confirmation
                        await _deleteReceipt();
                        Navigator.of(context).pop();
                      },
                      child: deleteText,
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(), // Close dialog
                      child: closeText,
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<void> _deleteReceipt() async {
    bool confirmed = await _confirmDeleteReceipt();
    if (confirmed) {
      // ignore: use_build_context_synchronously
      bool deleted = await Provider.of<ExpenseProvider>(context, listen: false)
          .deleteReceipt(widget.expense.id!);
      if (!deleted) {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DefaultErrorDialog(
                  errorMessage: receiptDeleteFail(widget.expense.id!));
            });
      } else {
        // TODO - show success snackbar
        if (mounted) {
          setState(() {
            hasReceipt = false;
          });
        }
      }
    }
  }

  Future<void> _saveReceiptToCameraRoll() async {
    if (!await _checkStoragePerms()) {
      await [
        Permission.photos,
        Permission.videos,
      ].request();
    }
    if (!await _checkStoragePerms()) {
      // ignore: use_build_context_synchronously
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return DefaultErrorDialog(errorMessage: noStoragePerms);
          });
    }

    try {
      String imgUrl = await Provider.of<ExpenseProvider>(context, listen: false)
          .getReceiptUrlForExpense(widget.expense.id!);
      final bytes = await readBytes(Uri.parse(imgUrl));
      final result = await ImageGallerySaver.saveImage(bytes);
      if (result["isSuccess"]) {
        //TODO - success snakcbar
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DefaultErrorDialog(errorMessage: "Failed to save receipt");
            });
      }
    } catch (e) {
//TODO - error handling
    }
  }

  Future<bool> _checkStoragePerms() async {
    return await Permission.photos.isGranted &&
        await Permission.videos.isGranted;
  }

// Used to verify deletion of receipt by user
  Future<bool> _confirmDeleteReceipt() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: askToDeleteReceiptTitle,
              content: askToDeleteReceipt,
              actions: <Widget>[
                TextButton(
                  child: cancelText,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: deleteText,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // Returning false if null (dialog dismissed)
  }
}
