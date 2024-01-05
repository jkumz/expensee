import 'package:expensee/app.dart';
import 'package:expensee/components/buttons/board_settings/add_user_button.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/expense_boards/board_settings_screen.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/login.dart';
import 'package:flutter/material.dart';

class ExpenseBoardNavBar extends StatefulWidget {
  final String boardId;

  const ExpenseBoardNavBar({Key? key, required this.boardId});

  @override
  createState() => _ExpenseBoardNavBarState();
}

class _ExpenseBoardNavBarState extends State<ExpenseBoardNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 4,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back button
          if (Navigator.canPop(context))
            IconButton(
                onPressed: () => {Navigator.pop(context), _updateState()},
                icon: Icon(Icons.arrow_back)),
          // Home button
          IconButton(
              onPressed: () => Navigator.pushNamed(context, Home.routeName),
              icon: Icon(Icons.home)),
          // Sign out button
          IconButton(
              onPressed: () => {
                    Login.signOut(),
                    Navigator.of(context).pushReplacementNamed(loginRoute),
                    _updateState()
                  },
              icon: Icon(Icons.logout_rounded)),
          IconButton(
              icon: Image.asset(
                boardSettingsImagePath,
                height: 22.5,
                width: 22.5,
              ),
              onPressed: () => Navigator.pushNamed(
                  context, BoardSettingsScreen.routeName,
                  arguments: BoardSettingsScreenArguments(
                      id: widget.boardId,
                      role: "Owner"))) // TODO - dynamically provide role
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




// We need to make this stateful so that we can dynamically check navigation stack
// class ExpenseBoardNavBar extends StatefulWidget {
//   final String boardId, userRole;

//   const ExpenseBoardNavBar(
//       {Key? key, required this.boardId, required this.userRole});

//   @override
//   createState() => _ExpenseBoardNavBarState();
// }

// class _ExpenseBoardNavBarState extends State<ExpenseBoardNavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       shape: CircularNotchedRectangle(),
//       notchMargin: 4,
//       child: Row(
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           // Back button
//           if (Navigator.canPop(context))
//             IconButton(
//                 onPressed: () => {Navigator.pop(context), _updateState()},
//                 icon: Icon(Icons.arrow_back)),
//           // Home button
//           IconButton(
//               onPressed: () => Navigator.pushNamed(context, Home.routeName),
//               icon: Icon(Icons.home)),
//           // Sign out button
//           IconButton(
//               onPressed: () => {
//                     Login.signOut(),
//                     Navigator.of(context).pushReplacementNamed(loginRoute),
//                     _updateState()
//                   },
//               icon: Icon(Icons.logout_rounded)),
//           AddUserButton(
//               text: addUserText,
//               onPressed: () => Navigator.pushNamed(
//                   context, BoardSettingsScreen.routeName,
//                   arguments: BoardSettingsScreenArguments(
//                       id: widget.boardId, role: widget.userRole)))
//         ],
//       ),
//     );
//   }

//   void _updateState() {
//     setState(() {
//       // Leave blank - this is just to check state to update navigation stack
//     });
//   }
// }
