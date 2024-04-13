import 'package:expensee/components/calendar/date_picker.dart';
import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/models/expense_board/expense_board.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

var logger = Logger(printer: PrettyPrinter());

// ignore: must_be_immutable
class SearchForm extends StatefulWidget {
  String boardId;
  final Function(ExpenseBoard) onApplyFilter;

  SearchForm({super.key, required this.boardId, required this.onApplyFilter});

  @override
  createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  bool invertDates = false, invertCategories = false, invertUsers = false;

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

  void _updateDateRange(String start, String end, String text) {
    if (mounted) {
      setState(() {
        startDate = start;
        endDate = end;
        selectedDateText = text;
      });
    }
  }

  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: selectDateRange,
          content: SizedBox(
            height: 400,
            width: double.infinity,
            child: CustomDateRangePicker(onDateRangeSelected: _updateDateRange),
          ),
          actions: <Widget>[
            TextButton(
              child: cancelText,
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
        final tempSelectedCategories = [...selectedCategories];
        return AlertDialog(
          title: selectCategoriesPopupText,
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
                            value: tempSelectedCategories.contains(category),
                            onChanged: (bool? selected) {
                              if (selected != null) {
                                setState(() {
                                  // This is the StateSetter's setState - enables
                                  // auto-refresh for check boxes in real time
                                  if (selected) {
                                    tempSelectedCategories.add(category);
                                  } else {
                                    tempSelectedCategories.remove(category);
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
              child: cancelText,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: okText,
              onPressed: () {
                if (mounted) {
                  setState(() {
                    selectedCategories = tempSelectedCategories;
                  });
                }
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
            selectCategoriesPopupText,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            _filterExpenses(
                selectedUserIDs, selectedCategories, startDate, endDate);
          },
          child: const Text('Apply Filters'),
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
      displayText = _getSelectedUserEmails().first;
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
                if (mounted) {
                  setState(() {
                    // Update the main state
                    selectedUserIDs = tempSelectedUserIDs;
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String _buildInversionText() {
    if (invertDates || invertCategories || invertUsers) {
      List<String> selectedOptions = [];
      if (invertDates) {
        selectedOptions.add('Dates');
      }
      if (invertCategories) {
        selectedOptions.add('Categories');
      }
      if (invertUsers) {
        selectedOptions.add('Users');
      }
      return 'Inverted Filters: ${selectedOptions.join(', ')}';
    } else {
      return 'Select Inversion';
    }
  }

  Widget _buildInversionSelectionRow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: _showInversionSelectionDialog,
              icon: const Icon(
                  Icons.filter_alt), // You can change the icon as needed
            ),
            const SizedBox(width: 8),
            const Text("Invert Filters?"),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _showInversionSelectionDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _buildInversionText(),
                    style: TextStyle(
                      color: invertDates || invertCategories || invertUsers
                          ? Colors.black
                          : Colors.black54,
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

// helper method for selecting which filters to invert
  void _showInversionSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Initialize a temporary bool for each inversion option
        bool tempInvertDates = invertDates;
        bool tempInvertCategories = invertCategories;
        bool tempInvertUsers = invertUsers;

        // Initialize a list to hold the names of inverted options
        List<String> invertedOptions = [];

        return AlertDialog(
          title: const Text('Select Inversion Options'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Invert Dates'),
                    value: tempInvertDates,
                    onChanged: (newValue) {
                      setState(() {
                        tempInvertDates = newValue ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Invert Categories'),
                    value: tempInvertCategories,
                    onChanged: (newValue) {
                      setState(() {
                        tempInvertCategories = newValue ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Invert Users'),
                    value: tempInvertUsers,
                    onChanged: (newValue) {
                      setState(() {
                        tempInvertUsers = newValue ?? false;
                      });
                    },
                  ),
                ],
              );
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
                if (mounted) {
                  setState(() {
                    // Update the main state with the temporary values
                    invertDates = tempInvertDates;
                    invertCategories = tempInvertCategories;
                    invertUsers = tempInvertUsers;

                    // Update the list of inverted options
                    if (invertDates) {
                      invertedOptions.add('Dates');
                    }
                    if (invertCategories) {
                      invertedOptions.add('Categories');
                    }
                    if (invertUsers) {
                      invertedOptions.add('Users');
                    }
                  });
                }
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
            .fetchMemberRecords(widget.boardId)
            .onError((error, stackTrace) {
      logger.e(
          "Failed to fetch group member records\nStack trace:$stackTrace\nError:$error");
      return List.empty();
    });
  }

  Future<void> _fetchCategories(String boardId) async {
    boardCategories = await Provider.of<BoardProvider>(context, listen: false)
        .fetchCategories(widget.boardId)
        .onError((error, stackTrace) {
      logger.e(
          "Failed to fetch categories for board with ID $boardId\nStackrace:$stackTrace\nError:$error");
      return List.empty();
    });
  }

  // Passes necessary params to filter to provider, which interacts with repository
  // which in turn interacts with the service layer.
  Future<void> _filterExpenses(List<String> userIDs, List<String> categories,
      String startDate, String endDate) async {
    var filteredBoard = await Provider.of<BoardProvider>(context, listen: false)
        .applyFilter(userIDs, categories, startDate, endDate, widget.boardId,
            invertDates, invertCategories, invertUsers)
        .onError((error, stackTrace) {
      logger.e(
          "Failed to filter expenses for board with ID ${widget.boardId}\nStacktrace:$stackTrace\nError:$error");
    });
    if (filteredBoard != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Board ${widget.boardId} has had filters applied.")));
      widget.onApplyFilter(filteredBoard);
    } else {
      DefaultErrorDialog(errorMessage: "Failed to apply your filter.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            _buildDateSelectionRow(),
            const SizedBox(height: 12),
            _buildCategorySelectionRow(),
            const SizedBox(height: 12),
            _buildUserSelectionRow(),
            const SizedBox(height: 12),
            _buildInversionSelectionRow(),
            const SizedBox(height: 36),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }
}
