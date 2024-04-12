import 'package:expensee/app.dart';
import 'package:expensee/components/appbars/home_app_bar.dart';
import 'package:expensee/components/buttons/home_buttons/view_invites_button.dart';
import 'package:expensee/components/nav_bars/default_bottom_bar.dart';
import 'package:expensee/components/buttons/home_buttons/view_boards_button.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/screens/expense_boards/expense_board_selection_screen.dart';
import 'package:expensee/screens/invite_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:expensee/main.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";

  const Home({super.key});

  @override
  createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();

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

  void _navigateToInviteManagement() {
    String email = supabase.auth.currentUser!.email!;
    Navigator.of(context)
        .pushNamed(InviteManagementScreen.routeName, arguments: {
      "email": email,
      "status": "sent" //default
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomePageOptions();
  }

  Widget _buildHomePageOptions() {
    return Scaffold(
      appBar: HomeAppBar(),
      bottomNavigationBar: const DefaultBottomAppBar(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "Welcome ${supabase.auth.currentUser!.email}",
                    ),
                  ),
                  const SizedBox(height: 12),
                  ViewExpenseBoardsButton(
                    text: viewSoloExpenseBoardsBtnText,
                    imagePath: singleBoardImagePath,
                    onPressed: _navigateToSoloBoards,
                  ),
                  const SizedBox(height: 12),
                  ViewExpenseBoardsButton(
                    text: viewGroupExpenseBoardsBtnText,
                    imagePath: groupBoardImagePath,
                    onPressed: _navigateToGroupBoards,
                  ),
                  const SizedBox(height: 12),
                  ViewInvitesButton(
                    text: viewInvitesBtnText,
                    imagePath: viewInvitesImagePath,
                    onPressed: _navigateToInviteManagement,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
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
        ));
  }
}
