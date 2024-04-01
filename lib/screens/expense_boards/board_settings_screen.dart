import 'package:expensee/components/buttons/board_settings/add_user_button.dart';
import 'package:expensee/components/buttons/board_settings/delete_board_button.dart';
import 'package:expensee/components/buttons/board_settings/remove_user_button.dart';
import 'package:expensee/components/buttons/board_settings/manage_users_button.dart';
import 'package:expensee/components/buttons/board_settings/rename_board_button.dart';
import 'package:expensee/components/buttons/board_settings/pass_ownership_button.dart';
import 'package:expensee/components/forms/invite_member_form.dart';
import 'package:expensee/components/forms/manage_user_perms_form.dart';
import 'package:expensee/components/forms/remove_user_form.dart';
import 'package:expensee/components/forms/rename_board_form.dart';
import 'package:expensee/components/forms/transfer_ownership_form.dart';
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
      renameBoard = false,
      transferingOwnership = false;

  // TODO - restrict what gets rendered in each form based on whether admin or owner
  @override
  Widget build(BuildContext context) {
    if (inviteUsers) {
      return InviteUserForm(boardId: widget.boardId, role: widget.role);
    }

    if (removeUsers) {
      return RemoveUserForm(
        boardId: widget.boardId,
        role: widget.role,
      );
    }

    if (managePerms && widget.role == "owner") {
      return ManageUserPermsForm(boardId: widget.boardId);
    }

    if (renameBoard && widget.role == "owner") {
      return RenameBoardForm(boardId: widget.boardId);
    }

    if (transferingOwnership && widget.role == "owner") {
      return TransferOwnershipForm(
        boardId: widget.boardId,
        role: widget.role,
      );
    }

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
                    text: addUserText, onPressed: _navigateToInviteUserScreen),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RemoveUserButton(
                    text: removeUserText,
                    onPressed: _navigateToRemoveUserScreen),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ManageRolesButton(
                    text: manageUserRolesText,
                    onPressed: _navigateToRoleManagementScreen),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RenameBoardButton(
                    text: renameBoardText, onPressed: _navigateToNamingScreen),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PassOwnershipButton(
                    text: passOwnershipText,
                    onPressed: _navigateToOwnershipTransfer),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: DeleteBoardButton(
                    text: delBoardText, onPressed: _navigateToNamingScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInviteUserScreen() {
    setState(() {
      inviteUsers = true;
    });
  }

  void _navigateToRemoveUserScreen() {
    setState(() {
      removeUsers = true;
    });
  }

  void _navigateToRoleManagementScreen() {
    setState(() {
      managePerms = true;
    });
  }

  void _navigateToNamingScreen() {
    setState(() {
      renameBoard = true;
    });
  }

  void _navigateToOwnershipTransfer() {
    setState(() {
      transferingOwnership = true;
    });
  }
}
