import "dart:collection";
import 'package:json_annotation/json_annotation.dart';
import 'expense_date.dart';

class ExpenseDatesConverter
    implements JsonConverter<ExpenseDates?, List<dynamic>?> {
  const ExpenseDatesConverter();

// Go through each date, convert to String and Hash it, then map the hash to the date
// If no date then just return empty hashmap of dates
  @override
  HashMap<int, DateTime> fromJson(List<dynamic>? json) {
    final ExpenseDates datesHash = ExpenseDates();

    if (json == null) return datesHash;

    json.forEach((element) {
      final dateMap = element as Map<String, dynamic>;
      if (dateMap.values.isNotEmpty) {
        final dateString = dateMap.values.first;
        final date = stringToExpenseDate(dateString);

        datesHash[date.hashCode] = date;
      }
    });

    return datesHash;
  }

// We will never need to submit a list of calendar dates
  @override
  List toJson(ExpenseDates? object) {
    throw UnimplementedError();
  }
}
