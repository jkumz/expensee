import 'package:expensee/models/expense/expense_model.dart';
import 'package:json_annotation/json_annotation.dart';

part "expense_board.g.dart";

@JsonSerializable()
class ExpenseBoard {
  @JsonKey(includeIfNull: false)
  final int? id;

  @JsonKey(name: "creator_id", required: true)
  final creatorId;

  @JsonKey(name: "name", required: true)
  final String name;

  @JsonKey(name: "is_group", required: true)
  final bool isGroup;

  @JsonKey(name: "initial_balance", required: true)
  final double initialBalance;

  @JsonKey(name: "balance", required: true)
  double balance;

  List<Expense> expenses = [];

  ExpenseBoard(
      {this.id,
      required this.creatorId,
      required this.name,
      required this.isGroup,
      required this.balance,
      required this.initialBalance});

  Map<String, dynamic> toJson() => _$ExpenseBoardToJson(this);

  factory ExpenseBoard.fromJson(Map<String, dynamic> json) =>
      _$ExpenseBoardFromJson(json);

  bool equals(ExpenseBoard anotherBoard) {
    return id == anotherBoard.id &&
        creatorId == anotherBoard.creatorId &&
        name == anotherBoard.name &&
        isGroup == anotherBoard.isGroup &&
        initialBalance == anotherBoard.initialBalance &&
        balance == anotherBoard.balance;
  }
}
