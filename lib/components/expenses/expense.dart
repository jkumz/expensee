import 'package:expensee/config/constants.dart';
import 'package:expensee/models/expense/expense_model.dart';
import 'package:flutter/material.dart';

// Widget used to display an Expense object in human readable format
class ExpenseItem extends StatefulWidget {
  final Expense expense;

  ExpenseItem({required this.expense});

  @override
  State<StatefulWidget> createState() => _ExpenseItemState();
}

class _ExpenseItemState extends State<ExpenseItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(expenseItemPadding),
      child: Row(
        children: [
          Expanded(
              flex: expenseItemFlex,
              child:
                  Text(widget.expense.date.toString())), //TODO - fix formatting
          Expanded(flex: expenseItemFlex, child: Text(widget.expense.category)),
          Expanded(
              flex: expenseItemFlex,
              child: Text('\$${widget.expense.amount.toStringAsFixed(2)}')),
          Expanded(
              flex: expenseItemFlex,
              child: Text('\$${widget.expense.balance.toStringAsFixed(2)}')),
          Expanded(
              flex: expenseItemFlex,
              child: Text(widget.expense.description ?? '')),
        ],
      ),
    );
  }
}
