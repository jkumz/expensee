import 'package:expensee/models/expense/expense_model.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/screens/expense_boards/board_creation_screen.dart';
import 'package:expensee/screens/expense_boards/board_settings_screen.dart';
import 'package:expensee/screens/expense_boards/expense_board_screen.dart';
import 'package:expensee/screens/expense_boards/expense_creation_screen.dart';
import 'package:expensee/screens/home.dart';
import 'package:expensee/screens/login.dart';
import 'package:expensee/screens/expense_boards/expense_board_selection_screen.dart';
import 'package:flutter/material.dart';

import 'package:expensee/screens/splash.dart';
import 'package:provider/provider.dart';

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
          case SelectExpenseBoardsScreen.routeName:
            // Extract arguments passed in settings
            final args = settings.arguments as ViewExpenseBoardArguments;
            return MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                      create: (context) => BoardProvider(),
                      child: SelectExpenseBoardsScreen(
                          isGroupBoardScreen: args.isGroupBoard),
                    ));
          case BoardCreationScreen.routeName:
            return MaterialPageRoute(
                builder: (_) => const BoardCreationScreen());
          case ExpenseCreationScreen.routeName:
            final args = settings.arguments as ExpenseCreationSreenArguments;
            return MaterialPageRoute(
              builder: (_) => ExpenseCreationScreen(expense: args.expense),
            );
          case ExpenseBoardScreen.routeName:
            final args = settings.arguments as ExpenseBoardScreenArguments;
            return MaterialPageRoute(
                builder: (_) => ExpenseBoardScreen(boardId: args.id));
          case BoardSettingsScreen.routeName:
            final args = settings.arguments as BoardSettingsScreenArguments;
            return MaterialPageRoute(
                builder: (_) => BoardSettingsScreen(
                    id: int.parse(args.id), role: args.role));

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

  ExpenseCreationSreenArguments({required this.expense});
}
