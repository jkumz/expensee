import 'package:expensee/components/appbars/home_app_bar.dart';
import 'package:expensee/components/elevated_buttons/home_buttons/view_expense.dart';
import 'package:expensee/config/constants.dart';
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
            SignOutButton(const Text("Sign out"), () async {
              Login.signOut();
              Navigator.of(context).pushReplacementNamed(loginRoute);
            })
          ],
        ),
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
                  ViewExpenseButton(Text("View Your Expense Boards"), () {}),
                  SizedBox(height: 12, width: 18),
                  ViewExpenseButton(Text("View Group Expense Boards"), () {})
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
