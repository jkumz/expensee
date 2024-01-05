import 'package:expensee/components/bottom_bars/default_bottom_bar.dart';
import 'package:expensee/components/buttons/board_settings/add_user_button.dart';
import 'package:expensee/components/buttons/board_settings/delete_board_button.dart';
import 'package:expensee/components/buttons/board_settings/manage_users_button.dart';
import 'package:expensee/components/buttons/board_settings/rename_board_button.dart';
import 'package:expensee/config/constants.dart';
import 'package:flutter/material.dart';

class BoardSettingsScreen extends StatefulWidget {
  static const routeName = "/board-settings";
  final int id;
  final String role;

  const BoardSettingsScreen({Key? key, required this.id, required this.role});

  @override
  createState() => _BoardSettingsScreenState();
}

class _BoardSettingsScreenState extends State<BoardSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(boardSettingsAppBarTitle)),
      bottomNavigationBar: DefaultBottomAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AddUserButton(
                    text: addUserText, onPressed: _navigateToUserSelection),
              ),
              SizedBox(height: 12),
              Expanded(
                child: RemoveUserButton(
                    text: removeUserText, onPressed: _navigateToUserSelection),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ManageRolesButton(
                    text: manageUserRolesText,
                    onPressed: _navigateToUserSelection),
              ),
              SizedBox(height: 12),
              Expanded(
                child: RenameBoardButton(
                    text: renameBoardText, onPressed: _navigateToUserSelection),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserSelection() {}
}
