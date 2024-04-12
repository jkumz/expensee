import 'package:expensee/main.dart';
import 'package:expensee/models/expense/date_time_converter.dart';
import 'package:expensee/models/expense/expense_date.dart';
import 'package:expensee/models/expense/expense_dates_converter.dart';
import 'package:expensee/models/expense/receipt_model.dart';
import 'package:json_annotation/json_annotation.dart';

//TODO - add proper error handling + validation

//A model class for the expense data

part "expense_model.g.dart"; // Auto generated

@JsonSerializable()
@ExpenseDatesConverter()
@DateTimeConverter()
class Expense {
  @JsonKey(includeIfNull: false)
  int? id;

  @JsonKey(name: "creator_id", required: true)
  String? creatorId;

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

  List<Receipt>? receipts;

  void setId(int id) {
    this.id = id;
  }

  Expense(
      {required this.date,
      required this.category,
      required this.amount,
      required this.balance,
      String? creatorId,
      String? description,
      int? id})
      : description = description ?? "No description",
        creatorId = creatorId ?? supabase.auth.currentUser!.id;

  factory Expense.blank() {
    return Expense(
        date: DateTime.now(),
        category: "Uncategorized",
        amount: 0.00,
        balance: 0.00,
        description: "",
        creatorId: supabase.auth.currentUser!.id);
  }

// JSON Serialization
  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  static bool equals(Expense previous, Expense updated) {
    if (previous.toJson() != updated.toJson()) {
      return false;
    }
    return true;
  }

  void setData(String date) {
    try {
      DateTime tempDate = DateTime.parse(date);
      this.date = DateTime(tempDate.year, tempDate.month, tempDate.day);
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
      balance = previousBalance - expenseAmount;
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

  void uploadReceipt(List<Receipt> receipt) {
    try {
      receipts = receipt;
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }
}
