// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['date', 'category', 'amount', 'balance'],
  );
  return Expense(
      date: const DateTimeConverter().fromJson(json['date'] as String),
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      description: json['description'] as String?,
      id: json['id'] as int?,
      creatorId: json['creator_id'] as String);
}

Map<String, dynamic> _$ExpenseToJson(Expense instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['date'] = const DateTimeConverter().toJson(instance.date);
  val['category'] = instance.category;
  val['amount'] = instance.amount;
  val['balance'] = instance.balance;
  val['description'] = instance.description;
  val['creator_id'] = instance.creatorId;
  return val;
}
