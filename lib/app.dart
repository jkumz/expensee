import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/expense_boards/expense_board_screen.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/invite_management_screen.dart';
import 'package:expensee/screens/login.dart';
import 'package:expensee/screens/expense_boards/expense_board_selection_screen.dart';
import 'package:expensee/screens/sign_up.dart';
import 'package:flutter/material.dart';

import 'package:expensee/screens/splash.dart';

class ExpenseeApp extends StatelessWidget {
  const ExpenseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expensee',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 122, 67, 45)),
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
            final args = settings.arguments as LoginScreenArguments?;
            return MaterialPageRoute(
              builder: (_) => Login(),
            );
          case SignUp.routeName:
            return MaterialPageRoute(builder: (_) => const SignUp());
          case SelectExpenseBoardsScreen.routeName:
            // Extract arguments passed in settings
            final args = settings.arguments as ViewExpenseBoardArguments;
            return MaterialPageRoute(
                builder: (context) => SelectExpenseBoardsScreen(
                    isGroupBoardScreen: args.isGroupBoard));
          case BoardCreationScreen.routeName:
            return MaterialPageRoute(
                builder: (_) => const BoardCreationScreen());
          case ExpenseBoardScreen.routeName:
            final args = settings.arguments as ExpenseBoardScreenArguments;
            return MaterialPageRoute(
                builder: (_) => ExpenseBoardScreen(boardId: args.id));
          case InviteManagementScreen.routeName:
            final args = settings.arguments as Map<String, dynamic>;
            final String email = args["email"];
            final String status = args["status"];
            return MaterialPageRoute(
                builder: (_) => InviteManagementScreen(
                      email: email,
                      status: status,
                    ));
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

class ExpenseBoardScreenArguments {
  final String id;
  final bool isGroup;

  ExpenseBoardScreenArguments({required this.id, required this.isGroup});
}

class BoardSettingsScreenArguments {
  final String id, role;

  BoardSettingsScreenArguments({required this.id, required this.role});
}

class ExpenseCreationSreenArguments {
  final Expense expense;
  bool exists;

  ExpenseCreationSreenArguments({required this.expense, this.exists = false});
}

class LoginScreenArguments {
  String? followUpToken;
  String? followUpRoute;

  LoginScreenArguments({this.followUpToken, this.followUpRoute});
}
