import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/home.dart';
import 'package:flutter/material.dart';

class ExpenseBoardNavBar extends StatefulWidget {
  final String boardId;
  final VoidCallback settings;
  final VoidCallback search;
  final String role;

  const ExpenseBoardNavBar(
      {super.key,
      required this.boardId,
      required this.settings,
      required this.search,
      required this.role});

  @override
  createState() => _ExpenseBoardNavBarState();
}

class _ExpenseBoardNavBarState extends State<ExpenseBoardNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back button
          IconButton(
              onPressed: Navigator.canPop(context)
                  ? () => {Navigator.pop(context), _updateState()}
                  : null,
              icon: const Icon(Icons.arrow_back)),
          // Home button
          IconButton(
              onPressed: () => Navigator.pushNamed(context, Home.routeName),
              icon: const Icon(Icons.home)),
          // Search button
          IconButton(
              onPressed: () {
                widget.search();
              },
              icon: Image.asset(searchImagePath,
                  height: 20, width: 22.5)), //Search
          if (_canAccessSettings())
            IconButton(
                icon: Image.asset(
                  boardSettingsImagePath,
                  height: 22.5,
                  width: 22.5,
                ),
                onPressed: () {
                  widget.settings();
                })
        ],
      ),
    );
  }

  void _updateState() {
    setState(() {
      // Leave blank - this is just to check state to update navigation stack
    });
  }

  bool _canAccessSettings() =>
      (widget.role == "owner" || widget.role == "admin");
}
