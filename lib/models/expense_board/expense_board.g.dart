// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseBoard _$ExpenseBoardFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'creator_id',
      'name',
      'is_group',
      'initial_balance',
      'balance'
    ],
  );
  return ExpenseBoard(
    id: json['id'] as int?,
    creatorId: json['creator_id'],
    name: json['name'] as String,
    isGroup: json['is_group'] as bool,
    balance: (json['balance'] as num).toDouble(),
    initialBalance: (json['initial_balance'] as num).toDouble(),
  );
}

Map<String, dynamic> _$ExpenseBoardToJson(ExpenseBoard instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['creator_id'] = instance.creatorId;
  val['name'] = instance.name;
  val['is_group'] = instance.isGroup;
  val['initial_balance'] = instance.initialBalance;
  val['balance'] = instance.balance;
  return val;
}
