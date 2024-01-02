import 'dart:collection';
import 'package:intl/intl.dart';

// assign alias
typedef ExpenseDate = DateTime;
typedef ExpenseDates = HashMap<int, ExpenseDate>;

const String ExpenseDateFormat = "yyyy-MM-dd"; // to match Supabase

String expenseDateToString(ExpenseDate date) {
  return DateFormat(ExpenseDateFormat).format(date);
}

ExpenseDate stringToExpenseDate(String value) {
  return DateTime.parse("$value 00:00:00Z");
}
