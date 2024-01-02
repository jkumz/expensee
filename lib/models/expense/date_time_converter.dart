import 'package:json_annotation/json_annotation.dart';
import 'expense_date.dart';

// A class used to convert DateTime to and from JSON format
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

// Used when pulling DateTime from Supabase backend
  @override
  DateTime fromJson(String json) {
    if (DateTime == null) return DateTime.parse("0000-00-00 00:00:00Z");
    return DateTime.parse(json);
  }

// Used when adding DateTime to Supabase backend
  @override
  String toJson(DateTime dateTime) {
    if (dateTime == null) return "0000-00-00 00:00:00Z";
    return expenseDateToString(dateTime);
  }
}
