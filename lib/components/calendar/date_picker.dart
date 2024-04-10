import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

typedef DateRangeUpdateCallback = void Function(
    String startDate, String endDate, String selectedDateText);

class CustomDateRangePicker extends StatelessWidget {
  final DateRangeUpdateCallback onDateRangeSelected;

  const CustomDateRangePicker({Key? key, required this.onDateRangeSelected})
      : super(key: key);

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
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
