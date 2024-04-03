import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/login.dart';
import 'package:flutter/material.dart';

class ExpenseBoardNavBar extends StatefulWidget {
  final String boardId;
  final VoidCallback settings;
  final String role;

  const ExpenseBoardNavBar(
      {super.key,
      required this.boardId,
      required this.settings,
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
          // Sign out button
          IconButton(
              onPressed: () => {
                    Login.signOut(),
                    Navigator.of(context).pushReplacementNamed(loginRoute),
                    _updateState()
                  },
              icon: const Icon(Icons.logout_rounded)),
          if (_canAccessSettings())
            IconButton(
                icon: Image.asset(
                  boardSettingsImagePath,
                  height: 22.5,
                  width: 22.5,
                ),
                onPressed: () {
                  widget.settings();
                }) // TODO - dynamically provide role
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
