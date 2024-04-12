import 'dart:collection';
import 'package:intl/intl.dart';

// assign alias
typedef ExpenseDate = DateTime;
typedef ExpenseDates = HashMap<int, ExpenseDate>;

const String expaneDateFormat = "yyyy-MM-dd"; // to match Supabase

String expenseDateToString(ExpenseDate date) {
  return DateFormat(expaneDateFormat).format(date);
}

ExpenseDate stringToExpenseDate(String value) {
  return DateTime.parse("$value 00:00:00Z");
}
