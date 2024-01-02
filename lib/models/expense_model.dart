import 'package:expensee/models/date_time_converter.dart';
import 'package:expensee/models/expense_date.dart';
import 'package:expensee/models/expense_dates_converter.dart';
import "package:flutter/material.dart";
import 'package:json_annotation/json_annotation.dart';

//TODO - add proper error handling + validation
// - positive balances only
// - type validation
// - length validation
// - popups presenting error in user friendly manner

//A model class for the expense data

part "expense_model.g.dart"; // Auto generated

@JsonSerializable()
@ExpenseDatesConverter()
@DateTimeConverter()
class Expense {
  @JsonKey(includeIfNull: false)
  int? id;

  @JsonKey(name: "date", required: true)
  ExpenseDate date;

  @JsonKey(name: "category", required: true)
  String category;

  @JsonKey(name: "amount", required: true)
  double amount;

  @JsonKey(name: "balance", required: true)
  double balance;

  @JsonKey(name: "description", required: false)
  String? description;

  Expense(
      {required this.date,
      required this.category,
      required this.amount,
      required this.balance,
      String? description,
      int? id})
      : this.description = description ?? "No description";

// TODO - Dyanmic balances
  factory Expense.blank() {
    return Expense(
      date: DateTime.now(),
      category: "Uncategorized",
      amount: 0.00,
      balance: 0.00,
      description: "",
    );
  }

// JSON Serialization
  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  void setData(String date) {
    try {
      DateTime tempDate =
          DateTime.parse(date) ?? DateTime.parse("00-00-0000 00:00:00Z");
      this.date = DateTime(tempDate.year, tempDate.month, tempDate.day);
    } catch (unknownError) {
      print(unknownError.toString());
    }
  }

  void setCategory(String category) {
    try {
      this.category = category ?? "Uncategorized";
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
      this.description = description ?? "";
    } catch (unknownError) {
      print(unknownError.toString());
    }
  }
}
