import "dart:js_interop";

import "package:flutter/material.dart";

//TODO - add proper error handling + validation
// - positive balances only
// - type validation
// - length validation
// - popups presenting error in user friendly manner

//A model class for the expense data
class Expense {
  String data;
  String category;
  double amount;
  double balance;
  String? description;

  Expense(
      {required this.data,
      required this.category,
      required this.amount,
      required this.balance,
      String? description})
      : this.description = description ?? "No description";

  void setData(String data) {
    try {
      this.data = data;
    } catch (unknownError) {
      print(unknownError.toString());
    }
  }

  void setCategory(String category) {
    try {
      this.category = category;
    } catch (unknownError) {
      print(unknownError.toString());
    }
  }

  void setAmount(double amount) {
    try {
      this.amount = amount;
      _setBalance(balance, amount);
    } catch (unknownError) {
      print(unknownError.toString());
    }
  }

  void _setBalance(double previousBalance, double expenseAmount) {
    try {
      this.balance = previousBalance - expenseAmount;
    } catch (unknownError) {
      // error handling
    }
  }

  void setDescription(String description) {
    try {
      this.description = description;
    } catch (unknownError) {
      print(unknownError.toString());
    }
  }
}
