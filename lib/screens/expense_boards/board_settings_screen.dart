import 'package:expensee/components/buttons/board_settings/add_user_button.dart';
import 'package:expensee/components/buttons/board_settings/delete_board_button.dart';
import 'package:expensee/components/buttons/board_settings/manage_users_button.dart';
import 'package:expensee/components/buttons/board_settings/rename_board_button.dart';
import 'package:expensee/components/forms/invite_member_form.dart';
import 'package:expensee/config/constants.dart';
import 'package:flutter/material.dart';

class BoardSettingsScreen extends StatefulWidget {
  static const routeName = "/board-settings";
  final String id;
  final String role;
  final String boardId;

  const BoardSettingsScreen(
      {Key? key, required this.id, required this.role, required this.boardId});

  @override
  createState() => _BoardSettingsScreenState();
}

class _BoardSettingsScreenState extends State<BoardSettingsScreen> {
  bool inviteUsers = false,
      removeUsers = false,
      managePerms = false,
      renameBoard = false;
  @override
  Widget build(BuildContext context) {
    if (inviteUsers) return InviteUserForm(boardId: widget.boardId);
    // add conditionals for other options
    return Scaffold(
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

  void _navigateToUserSelection() {
    setState(() {
      inviteUsers = true;
    });
  }
}
