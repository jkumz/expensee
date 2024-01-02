import 'package:expensee/components/forms/create_expense_board_form.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/expense_boards/group_expense_boards_view.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/login.dart';
import 'package:expensee/screens/expense_boards/solo_expense_boards_view.dart';
import 'package:flutter/material.dart';

import 'package:expensee/screens/splash.dart';

class ExpenseeApp extends StatelessWidget {
  const ExpenseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expensee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: Splash.routeName, // TODO Splash.routeName
      routes: {
        Splash.routeName: (context) => const Splash(),
        Home.routeName: (context) => const Home(),
        Login.routeName: (context) => const Login(),
        ViewExpenseBoardsSolo.routeName: (context) =>
            const ViewExpenseBoardsSolo(),
        ViewExpenseBoardsGroups.routeName: (context) =>
            const ViewExpenseBoardsGroups(),
        BoardCreationScreen.routeName: (context) => const BoardCreationScreen()
      },
    );
  }
}
