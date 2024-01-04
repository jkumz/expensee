import 'package:expensee/components/forms/create_expense_board_form.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/login.dart';
import 'package:expensee/screens/expense_boards/expense_boards_screen.dart';
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
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case Splash.routeName:
            return MaterialPageRoute(builder: (_) => const Splash());
          case Home.routeName:
            return MaterialPageRoute(builder: (_) => const Home());
          case Login.routeName:
            return MaterialPageRoute(builder: (_) => const Login());
          case ViewExpenseBoards.routeName:
            // Extract arguments passed in settings
            final args = settings.arguments as ViewExpenseBoardArguments;
            return MaterialPageRoute(
              builder: (_) =>
                  ViewExpenseBoards(isGroupBoardScreen: args.isGroupBoard),
            );
          case BoardCreationScreen.routeName:
            return MaterialPageRoute(
                builder: (_) => const BoardCreationScreen());
          default:
            return MaterialPageRoute(builder: (_) => const Splash());
        }
      },
    );
  }
}

class ViewExpenseBoardArguments {
  final bool isGroupBoard;

  ViewExpenseBoardArguments({required this.isGroupBoard});
}
