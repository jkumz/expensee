import 'package:expensee/app.dart';
import 'package:expensee/components/appbars/home_app_bar.dart';
import 'package:expensee/components/nav_bars/default_bottom_bar.dart';
import 'package:expensee/components/buttons/home_buttons/create_board_button.dart';
import 'package:expensee/components/buttons/home_buttons/view_boards_button.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/expense_boards/expense_board_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensee/main.dart';
import 'package:expensee/screens/login.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";

  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();

  var _loading = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _navigateToSoloBoards() {
    Navigator.of(context).pushNamed(SelectExpenseBoardsScreen.routeName,
        arguments: ViewExpenseBoardArguments(isGroupBoard: false));
  }

  void _navigateToGroupBoards() {
    Navigator.of(context).pushNamed(SelectExpenseBoardsScreen.routeName,
        arguments: ViewExpenseBoardArguments(isGroupBoard: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: HomeAppBar(
          actions: [
            // TODO
          ],
        ),
        bottomNavigationBar: DefaultBottomAppBar(),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    "Welcome ${supabase.auth.currentUser!.email}",
                    style: TextStyle(/**TODO - Create this style */),
                  ),
                  SizedBox(height: 12, width: 18),
                  ViewExpenseBoardsButton(
                      text: ViewSoloExpenseBoardsBtnText,
                      imagePath: singleBoardImagePath,
                      onPressed: _navigateToSoloBoards),
                  SizedBox(height: 12, width: 18),
                  ViewExpenseBoardsButton(
                      text: ViewGroupExpenseBoardsBtnText,
                      imagePath: groupBoardImagePath,
                      onPressed: _navigateToGroupBoards),
                  SizedBox(height: 12, width: 18),
                ],
              ),
            )
          ],
        ));
  }
}

class SignOutButton extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onTap;
  final Color? textColour;
  final Color? backgroundColour;

  const SignOutButton(this.child, this.onTap,
      {Key? key, this.textColour, this.backgroundColour})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: child,
      style: ElevatedButton.styleFrom(
          foregroundColor: (textColour ?? Colors.white),
          backgroundColor:
              (backgroundColour ?? const Color.fromARGB(255, 170, 76, 175)),
          elevation: 1,
          textStyle: TextStyle(/*TODO make custom text styles*/)),
    );
  }
}
