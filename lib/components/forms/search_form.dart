import 'package:expensee/config/constants.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SearchForm extends StatefulWidget {
  String boardId;

  SearchForm({super.key, required this.boardId});

  @override
  createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  String startDate = "", endDate = "";
  String selectedDateText = "None Selected";

  List<String> boardCategories = [];
  List<String> selectedCategories = [];

  // We need user emails to get their ID, but we only need their IDs for the query
  List<(String userId, String userEmail)> userIdToEmailRecords = [];
  List<String> selectedUserIDs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    await _fetchCategories(widget.boardId);
    await _fetchGroupMembers(widget.boardId);
  }

  void _onDatePickerSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      // update date range strings
      setState(() {
        startDate = "${args.value.startDate}";
        endDate = "${args.value.endDate ?? args.value.startDate}";
        if (args.value.startDate != null && args.value.endDate != null) {
          selectedDateText =
              "${DateFormat("dd-MM-yyyy").format(args.value.startDate)} - ${DateFormat("dd-MM-yyyy").format(args.value.endDate)}";
        } else if (args.value.startDate != null) {
          selectedDateText =
              "${DateFormat("dd-MM-yyyy").format(args.value.startDate)}";
        }
      });
    }
  }

  Widget _renderDatePicker() {
    return SfDateRangePicker(
      view: DateRangePickerView.year,
      onSelectionChanged: _onDatePickerSelectionChanged,
      selectionMode: DateRangePickerSelectionMode.range,
      initialSelectedRange: PickerDateRange(
          DateTime.now().subtract(const Duration(days: 1)), DateTime.now()),
    );
  }

  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Range'),
          content: SizedBox(
            height: 400,
            width: double.infinity,
            child: _renderDatePicker(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Date update done in its own method internally
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitle() {
    return const Center(
        child: Text(
      "Filter Expenses",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
    ));
  }

// Renders the row containing date picker
  Widget _buildDateSelectionRow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: _showDatePickerDialog,
                icon: Image.asset(
                  calendarImagePath,
                  height: 30,
                  width: 30,
                )),
            const SizedBox(
                width: 8), // Provides space between the icon and the text
            const Text("Select Dates"),
            const SizedBox(
                width: 8), // Provides space between the icon and the text
            Expanded(
              child: GestureDetector(
                onTap: _showDatePickerDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedDateText,
                    style: TextStyle(
                      color: Colors.black54,
                      fontStyle: selectedDateText.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// helper method for displaying category selection menu
  void _showCategoryPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // copy already selected categories over
        final _tempSelectedCategories = [...selectedCategories];
        return AlertDialog(
          title: Text('Select Categories'),
          content: StatefulBuilder(
            // This will allow us to update the dialog's content.
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: boardCategories
                      .map((category) => CheckboxListTile(
                            title: Text(category),
                            // tick the box if its alrdy in selected categories
                            value: _tempSelectedCategories.contains(category),
                            onChanged: (bool? selected) {
                              if (selected != null) {
                                setState(() {
                                  // This is the StateSetter's setState - enables
                                  // auto-refresh for check boxes in real time
                                  if (selected) {
                                    _tempSelectedCategories.add(category);
                                  } else {
                                    _tempSelectedCategories.remove(category);
                                  }
                                });
                              }
                            },
                          ))
                      .toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  selectedCategories = _tempSelectedCategories;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

// Renders the row containing the category picker
  Widget _buildCategorySelectionRow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: _showCategoryPickerDialog,
              icon: Image.asset(
                categoryImagePath,
                height: 30,
                width: 30,
              ),
            ),
            const SizedBox(width: 8),
            const Text("Select Categories"),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _showCategoryPickerDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedCategories
                        .join(', '), // Display selected categories
                    style: TextStyle(
                      color: Colors.black54,
                      fontStyle: selectedCategories.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceBetween, // Aligns children to each side of the row
      children: [
        // Placeholder for checkboxes you might add later
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // TODO: add checkboxes for inverting user selection, date, users
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: search button
          },
          child: Text('Search'),
        ),
      ],
    );
  }

// Goes through user's selected emails and returns a list of matching user IDs
// $1 corresponds to ID, $2 to email
  List<String> _getSelectedUserEmails() {
    return selectedUserIDs
        .map((id) => userIdToEmailRecords
            .firstWhere((record) => record.$1 == id, orElse: () => ('', ''))
            .$2)
        .where((email) => email.isNotEmpty)
        .toList();
  }

  Widget _buildUserSelectionRow() {
    String displayText;
    if (selectedUserIDs.isEmpty) {
      displayText = 'No users selected';
    } else if (selectedUserIDs.length == 1) {
      // Assuming _getSelectedUserEmails returns the emails in the same order as the IDs
      displayText = '${_getSelectedUserEmails().first}';
    } else {
      // Display the first email and the count of the remaining selected users
      displayText =
          '${_getSelectedUserEmails().first} + ${selectedUserIDs.length - 1} other users';
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: _showUserPickerDialog,
              icon: Image.asset(
                userSelectionImagePath,
                height: 30,
                width: 30,
              ),
            ),
            const SizedBox(width: 8),
            const Text("Select Users"),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _showUserPickerDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    // Assuming you'll implement a method to convert selectedUserIDs to emails for display
                    displayText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helper method for displaying user selection menu
  void _showUserPickerDialog() {
    // Initialize a temporary list with the already selected user IDs for comparison
    final tempSelectedUserIDs = [...selectedUserIDs];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Users'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    children: userIdToEmailRecords
                        .map((record) => CheckboxListTile(
                              title: Text(record.$2), // Display email
                              value: tempSelectedUserIDs.contains(record
                                  .$1), // Check if the user ID is already selected, if it is have it ticked
                              onChanged: (bool? selected) {
                                if (selected != null) {
                                  setState(() {
                                    // Update state within dialog
                                    if (selected == true) {
                                      if (!tempSelectedUserIDs
                                          .contains(record.$1)) {
                                        tempSelectedUserIDs.add(record.$1);
                                      }
                                    } else {
                                      tempSelectedUserIDs.remove(record.$1);
                                    }
                                  });
                                }
                              },
                            ))
                        .toList(),
                  ));
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  // Update the main state
                  selectedUserIDs = tempSelectedUserIDs;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchGroupMembers(String boardId) async {
    userIdToEmailRecords =
        await Provider.of<BoardProvider>(context, listen: false)
            .fetchMemberRecords(widget.boardId);
  }

  Future<void> _fetchCategories(String boardId) async {
    boardCategories = await Provider.of<BoardProvider>(context, listen: false)
        .fetchCategories(widget.boardId);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(flex: 1, child: _buildTitle()),
            Expanded(flex: 1, child: _buildDateSelectionRow()),
            Expanded(flex: 1, child: _buildCategorySelectionRow()),
            Expanded(flex: 1, child: _buildUserSelectionRow()),
            const Spacer(),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // aligns children to each side of the row
                children: [
                  // TODO - add check boxes inverting filters - users/date/categories
                  Expanded(flex: 1, child: _buildSearchButton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
