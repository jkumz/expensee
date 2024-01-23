// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseBoard _$ExpenseBoardFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['owner_id', 'name', 'is_group'],
  );
  return ExpenseBoard(
      id: json['id'] as int?,
      ownerId: json['owner_id'],
      name: json['name'] as String,
      isGroup: json['is_group'] as bool,
      balance: json['balance'] as double);
}

Map<String, dynamic> _$ExpenseBoardToJson(ExpenseBoard instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['owner_id'] = instance.ownerId;
  val['name'] = instance.name;
  val['is_group'] = instance.isGroup;
  val['balance'] = instance.balance;
  return val;
}
