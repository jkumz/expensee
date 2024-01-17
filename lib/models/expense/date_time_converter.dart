import 'package:json_annotation/json_annotation.dart';
import 'expense_date.dart';

// A class used to convert DateTime to and from JSON format
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

// Used when pulling DateTime from Supabase backend
  @override
  DateTime fromJson(String date) {
    if (date.isEmpty) return DateTime.parse("0000-00-00 00:00:00Z");
    return DateTime.parse(date);
  }

// Used when adding DateTime to Supabase backend
  @override
  String toJson(DateTime dateTime) {
    return expenseDateToString(dateTime);
  }
}
