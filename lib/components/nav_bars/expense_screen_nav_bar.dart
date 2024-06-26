import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/login.dart';
import 'package:flutter/material.dart';

class ExpenseScreenNavBar extends StatefulWidget {
  final String boardId;
  final VoidCallback exit;

  const ExpenseScreenNavBar(
      {super.key, required this.boardId, required this.exit});

  @override
  createState() => _ExpenseScreenNavBarState();
}

class _ExpenseScreenNavBarState extends State<ExpenseScreenNavBar> {
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
              onPressed: Navigator.canPop(context) ? widget.exit : null,
              icon: const Icon(Icons.arrow_back)),
          // Home button
          IconButton(
              onPressed: () {
                // Obtain the current route's name
                String? currentRouteName =
                    ModalRoute.of(context)?.settings.name;

                // Check if the current route is not the Home page before navigating
                if (currentRouteName != Home.routeName) {
                  Navigator.pushNamed(context, Home.routeName);
                }
              },
              icon: const Icon(Icons.home)),
          // Sign out button
          IconButton(
              onPressed: () => {
                    Login.signOut(context),
                    Navigator.of(context).pushReplacementNamed(loginRoute),
                    _updateState()
                  },
              icon: const Icon(Icons.logout_rounded)),
        ],
      ),
    );
  }

  void _updateState() {
    setState(() {
      // Leave blank - this is just to check state to update navigation stack
    });
  }
}
