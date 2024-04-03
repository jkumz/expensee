// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
      expenseId: json['expenseId'] as String,
      filePath: json['filePath'] as String,
      uploadDate: json['uploadDate'] as String,
    );

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
      'expenseId': instance.expenseId,
      'filePath': instance.filePath,
      'uploadDate': instance.uploadDate,
    };
