import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

var logger = Logger(
  printer: PrettyPrinter(), // Use the PrettyPrinter for easy-to-read logging
);

typedef DateRangeUpdateCallback = void Function(
    String startDate, String endDate, String selectedDateText);

class CustomDateRangePicker extends StatelessWidget {
  final DateRangeUpdateCallback onDateRangeSelected;

  const CustomDateRangePicker({Key? key, required this.onDateRangeSelected})
      : super(key: key);

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    try {
      String startDate = '';
      String endDate = '';
      String selectedDateText = '';

      if (args.value is PickerDateRange) {
        final PickerDateRange range = args.value;
        if (range.startDate != null) {
          startDate = startDate = "${args.value.startDate}";
          if (range.endDate != null) {
            endDate = "${args.value.endDate}";
          } else {
            endDate = startDate;
          }
          selectedDateText =
              range.endDate != null ? "$startDate - $endDate" : startDate;
        }

        onDateRangeSelected(startDate, endDate, selectedDateText);
      }
    } catch (e) {
      logger.e("Failed to apply dates selected");
      logger.e("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfDateRangePicker(
      view: DateRangePickerView.month,
      onSelectionChanged: _onSelectionChanged,
      selectionMode: DateRangePickerSelectionMode.range,
    );
  }
}
