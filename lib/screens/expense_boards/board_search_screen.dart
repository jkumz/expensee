import 'package:expensee/components/buttons/board_settings/add_user_button.dart';
import 'package:expensee/components/buttons/board_settings/delete_board_button.dart';
import 'package:expensee/components/buttons/board_settings/mass_email_button.dart';
import 'package:expensee/components/buttons/board_settings/remove_user_button.dart';
import 'package:expensee/components/buttons/board_settings/manage_users_button.dart';
import 'package:expensee/components/buttons/board_settings/rename_board_button.dart';
import 'package:expensee/components/buttons/board_settings/pass_ownership_button.dart';
import 'package:expensee/components/forms/invite_member_form.dart';
import 'package:expensee/components/forms/manage_user_perms_form.dart';
import 'package:expensee/components/forms/mass_email_form.dart';
import 'package:expensee/components/forms/remove_user_form.dart';
import 'package:expensee/components/forms/rename_board_form.dart';
import 'package:expensee/components/forms/search_form.dart';
import 'package:expensee/components/forms/transfer_ownership_form.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/util/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoardSearchScreen extends StatefulWidget {
  static const routeName = "/board-settings";
  final String boardId;
  final bool isGroup;

  const BoardSearchScreen(
      {Key? key, required this.boardId, required this.isGroup});

  @override
  createState() => _BoardSearchScreenState();
}

class _BoardSearchScreenState extends State<BoardSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchForm(boardId: widget.boardId),
    );
  }
}
