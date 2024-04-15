// ignore_for_file: use_build_context_synchronously

import 'package:expensee/components/buttons/board_settings/add_user_button.dart';
import 'package:expensee/components/buttons/board_settings/delete_board_button.dart';
import 'package:expensee/components/buttons/board_settings/download_receipts_button.dart';
import 'package:expensee/components/buttons/board_settings/manage_users_button.dart';
import 'package:expensee/components/buttons/board_settings/mass_email_button.dart';
import 'package:expensee/components/buttons/board_settings/pass_ownership_button.dart';
import 'package:expensee/components/buttons/board_settings/remove_user_button.dart';
import 'package:expensee/components/buttons/board_settings/rename_board_button.dart';
import 'package:expensee/components/calendar/date_picker.dart';
import 'package:expensee/components/dialogs/default_error_dialog.dart';
import 'package:expensee/components/dialogs/default_success_dialog.dart';
import 'package:expensee/components/forms/invite_member_form.dart';
import 'package:expensee/components/forms/manage_user_perms_form.dart';
import 'package:expensee/components/forms/mass_email_form.dart';
import 'package:expensee/components/forms/remove_user_form.dart';
import 'package:expensee/components/forms/rename_board_form.dart';
import 'package:expensee/components/forms/transfer_ownership_form.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/expense_provider.dart';
import 'package:expensee/util/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

var logger = Logger(
  printer: PrettyPrinter(), // Use the PrettyPrinter for easy-to-read logging
);

class BoardSettingsScreen extends StatefulWidget {
  static const routeName = "/board-settings";
  final String id;
  final String role;
  final String boardId;
  final bool isGroup;

  const BoardSettingsScreen(
      {super.key,
      required this.id,
      required this.role,
      required this.boardId,
      required this.isGroup});

  @override
  createState() => _BoardSettingsScreenState();
}

class _BoardSettingsScreenState extends State<BoardSettingsScreen> {
  bool inviteUsers = false,
      removeUsers = false,
      managePerms = false,
      renameBoard = false,
      transferingOwnership = false,
      massEmail = false,
      filterExpenses = true;

  @override
  Widget build(BuildContext context) {
    if (inviteUsers && widget.isGroup) {
      return InviteUserForm(boardId: widget.boardId, role: widget.role);
    } else if (removeUsers && widget.isGroup) {
      return RemoveUserForm(
        boardId: widget.boardId,
        role: widget.role,
      );
    } else if (managePerms && widget.isGroup) {
      return ManageUserPermsForm(boardId: widget.boardId);
    } else if (renameBoard) {
      return RenameBoardForm(boardId: widget.boardId);
    } else if (transferingOwnership && widget.isGroup) {
      return TransferOwnershipForm(
        boardId: widget.boardId,
        role: widget.role,
      );
    } else if (massEmail && widget.isGroup) {
      return MassEmailForm(boardId: widget.boardId);
    }

    // add conditionals for other options
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: widget.isGroup
                ? _buildGroupButtonList()
                : _buildSoloButtonList(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSoloButtonList() {
    return [
      Expanded(
        child: AddUserButton(
          text: addUserText,
          onPressed: _navigateToInviteUserScreen,
          isEnabled: false,
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: RemoveUserButton(
          text: removeUserText,
          onPressed: _navigateToRemoveUserScreen,
          isEnabled: false,
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: ManageRolesButton(
            text: manageUserRolesText,
            isEnabled: false,
            onPressed: _navigateToRoleManagementScreen),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: RenameBoardButton(
          text: renameBoardText,
          onPressed: _navigateToNamingScreen,
          isEnabled: _checkIfOwner(),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: PassOwnershipButton(
          text: passOwnershipText,
          onPressed: _navigateToOwnershipTransfer,
          isEnabled: false,
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: MassEmailButton(
          text: massEmailText,
          onPressed: _navigateToMassEmailScreen,
          isEnabled: false,
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: DownloadReceiptsButton(
          text: downloadReceiptsText,
          onPressed: _downloadAllReceipts,
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: DeleteBoardButton(
          text: delBoardText,
          onPressed: _confirmAndDeleteBoard,
          isEnabled: _checkIfOwner(),
        ),
      ),
    ];
  }

  List<Widget> _buildGroupButtonList() {
    return [
      Expanded(
        child: AddUserButton(
            text: addUserText, onPressed: _navigateToInviteUserScreen),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: RemoveUserButton(
            text: removeUserText, onPressed: _navigateToRemoveUserScreen),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: ManageRolesButton(
            text: manageUserRolesText,
            isEnabled: _checkIfOwner(),
            onPressed: _navigateToRoleManagementScreen),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: RenameBoardButton(
          text: renameBoardText,
          onPressed: _navigateToNamingScreen,
          isEnabled: _checkIfOwner(),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: PassOwnershipButton(
          text: passOwnershipText,
          onPressed: _navigateToOwnershipTransfer,
          isEnabled: _checkIfOwner(),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: MassEmailButton(
          text: massEmailText,
          onPressed: _navigateToMassEmailScreen,
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: DownloadReceiptsButton(
          text: downloadReceiptsText,
          onPressed: _downloadAllReceipts,
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: DeleteBoardButton(
          text: delBoardText,
          onPressed: _confirmAndDeleteBoard,
          isEnabled: _checkIfOwner(),
        ),
      ),
    ];
  }

// navigation controls
  void _navigateToInviteUserScreen() =>
      {if (mounted) setState(() => inviteUsers = true)};
  void _navigateToRemoveUserScreen() =>
      {if (mounted) setState(() => removeUsers = true)};
  void _navigateToRoleManagementScreen() =>
      {if (mounted) setState(() => managePerms = true)};
  void _navigateToNamingScreen() =>
      {if (mounted) setState(() => renameBoard = true)};
  void _navigateToOwnershipTransfer() =>
      {if (mounted) setState(() => transferingOwnership = true)};
  void _navigateToMassEmailScreen() =>
      {if (mounted) setState(() => massEmail = true)};

  Future<void> _confirmAndDeleteBoard() async {
    if (widget.role != "owner") return;
    bool deleteConfirmed =
        await DialogHelper.showConfirmationDialog(context, deleteBoardMessage);

    if (deleteConfirmed) {
      if (!mounted) return;
      bool deleted = await Provider.of<BoardProvider>(context, listen: false)
          .deletedBoard(widget.boardId)
          .onError((error, stackTrace) {
        logger.e(
            "Failed to delete board with ID ${widget.boardId}\nError:$error\nStacktrace:$stackTrace");
        return false;
      });

      if (deleted) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DefaultSuccessDialog(
                  successMessage: "Expense board deleted");
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DefaultErrorDialog(errorMessage: "Failed to delete board");
            });
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  bool _checkIfOwner() => widget.role == "owner";

  // we need to get a list of all expnese IDs in the board, then for eahc of those save it to camera roll
  Future<void> _downloadAllReceipts() async {
    try {
      String? start;
      String? end;

      // First, show the date picker dialog to let the user select a date range
      bool dateSelected = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Select Date Range"),
              content: CustomDateRangePicker(
                  onDateRangeSelected: (startDate, endDate, selectedDateText) {
                start = startDate;
                end = endDate;
              }),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // User cancelled
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                  },
                ),
              ],
            );
          });

      if (!dateSelected) return; // User cancelled the date selection

      // Check storage permissions
      if (!await _checkStoragePerms()) {
        await [Permission.photos, Permission.videos].request();
      }

      if (!await _checkStoragePerms()) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return DefaultErrorDialog(
                  errorMessage:
                      "Storage permissions are needed to save receipts.");
            });
      }

      bool pickedDates = ((start != null && end != null) || start != null);

      // If we got to this point, proceed with fetching expense IDs and downloading
      List<int> ids = pickedDates
          ? await Provider.of<ExpenseProvider>(context, listen: false)
              .getExpenseIdsForBoardWithDate(widget.boardId, start, end)
          : await Provider.of<ExpenseProvider>(context, listen: false)
              .getExpenseIdsForBoard(widget.boardId);

      if (ids.isEmpty) {
        showDialog(
            context: context,
            builder: (BuildContext) {
              return DefaultErrorDialog(
                  errorMessage:
                      "Failed to get expense IDs to download receipts - please try again");
            });
        Navigator.pop(context);
      }

      try {
        bool failedToSave = false;
        for (int id in ids) {
          if (!await Provider.of<ExpenseProvider>(context, listen: false)
              .hasReceipt(id)) continue; // skip if no receipt

          String imgUrl =
              await Provider.of<ExpenseProvider>(context, listen: false)
                  .getReceiptUrlForExpense(id);
          final bytes = await readBytes(Uri.parse(imgUrl));
          final uniqueIdentifier = const Uuid().v4();
          final result = await ImageGallerySaver.saveImage(bytes,
              name: "receipt_${id}_$uniqueIdentifier");

          failedToSave = !result["isSuccess"];
        }
        if (!failedToSave) {
          // Show success snackbar
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DefaultSuccessDialog(
                    successMessage: "All receipts saved successfully");
              });
        } else {
          // Show error dialog
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DefaultErrorDialog(
                    errorMessage: "Failed to save one or more receipts.");
              });
        }
      } catch (e) {
        // Handle errors
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DefaultErrorDialog(
                  errorMessage: "An error occurred while saving receipts.");
            });
      }
    } catch (e) {
      logger.e("Failed to download all receipts: $e");
    }
  }

  Future<bool> _checkStoragePerms() async {
    return await Permission.photos.isGranted &&
        await Permission.videos.isGranted;
  }
}
