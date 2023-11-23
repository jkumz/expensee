import 'package:flutter/material.dart';

import 'dart:core';

// expense object
class Expense {
  late int id; // not sure how to go about this, but I want it auto-gen'd
  late String? name;
  late String? category;
  late DateTime? expenseDate = DateTime.now(); // default value
  late double? amount;
  late String? description;

  // Constructor handling null values with defaults
  Expense(
      {String? name,
      String? category,
      DateTime? expenseDate,
      double? amount,
      String? description})
      : this.name = name ?? "Expense Name",
        this.category = category ?? "Uncategorised",
        this.amount = amount ?? 0.00,
        this.description = description ?? "An undescribed expense";

  // Blank expense - if user provides no input just use this
  Expense.blank()
      : name = "Expense name",
        category = "Uncategorised",
        amount = 0.00,
        description = "An undescribed expense";
}
