import 'package:json_annotation/json_annotation.dart';

part "receipt_model.g.dart"; // Auto generated

@JsonSerializable()
class Receipt {
  final String expenseId;
  final String filePath;
  final String uploadDate;

  Receipt(
      {required this.expenseId,
      required this.filePath,
      required this.uploadDate});

// JSON Serialization
  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptToJson(this);
}
