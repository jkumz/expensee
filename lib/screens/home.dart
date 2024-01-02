import 'package:expensee/components/appbars/home_app_bar.dart';
import 'package:expensee/components/bottom_bars/default_bottom_bar.dart';
import 'package:expensee/components/buttons/home_buttons/create_board_button.dart';
import 'package:expensee/components/buttons/home_buttons/view_expense.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/expense_boards/group_expense_boards_view.dart';
import 'package:expensee/screens/expense_boards/solo_expense_boards_view.dart';
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
                    "Welcome {email from supabase}",
                    style: TextStyle(/**TODO - Create this style */),
                  ),
                  SizedBox(height: 12, width: 18),
                  ViewExpenseButton(Text("View your Expense Board"), () {
                    Navigator.of(context)
                        .pushNamed(ViewExpenseBoardsSolo.routeName);
                  }),
                  SizedBox(height: 12, width: 18),
                  ViewExpenseButton(Text("View Group Expense Boards"), () {
                    Navigator.of(context)
                        .pushNamed(ViewExpenseBoardsGroups.routeName);
                  }),
                  SizedBox(height: 12, width: 18),
                  CreateExpenseBoardButton(Text("Create a new Expense Board"),
                      () {
                    Navigator.of(context)
                        .pushNamed(BoardCreationScreen.routeName);
                  })
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
