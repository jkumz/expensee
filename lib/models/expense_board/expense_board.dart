import 'package:json_annotation/json_annotation.dart';

part "expense_board.g.dart";

@JsonSerializable()
class ExpenseBoard {
  @JsonKey(includeIfNull: false)
  final int? id;

  @JsonKey(name: "owner_id", required: true)
  final ownerId;

  @JsonKey(name: "name", required: true)
  final String name;

  @JsonKey(name: "is_group", required: true)
  final bool isGroup;

  ExpenseBoard(
      {this.id,
      required this.ownerId,
      required this.name,
      required this.isGroup});

  Map<String, dynamic> toJson() => _$ExpenseBoardToJson(this);

  factory ExpenseBoard.fromJson(Map<String, dynamic> json) =>
      _$ExpenseBoardFromJson(json);
}
