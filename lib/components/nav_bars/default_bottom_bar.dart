import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/login.dart';
import 'package:flutter/material.dart';

// We need to make this stateful so that we can dynamically check navigation stack
class DefaultBottomAppBar extends StatefulWidget {
  const DefaultBottomAppBar({super.key});

  @override
  createState() => _DefaultBottomAppBarState();
}

class _DefaultBottomAppBarState extends State<DefaultBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Back button
          if (Navigator.canPop(context))
            IconButton(
                onPressed: () => {Navigator.pop(context), _updateState()},
                icon: const Icon(Icons.arrow_back)),
          // Home button
          IconButton(
              onPressed: () => Navigator.pushNamed(context, Home.routeName),
              icon: const Icon(Icons.home)),
          // Sign out button
          IconButton(
              onPressed: () => {
                    Login.signOut(context),
                    Navigator.of(context).pushReplacementNamed(loginRoute),
                    _updateState()
                  },
              icon: const Icon(Icons.logout_rounded))
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
