// ignore_for_file: use_build_context_synchronously

import 'package:expensee/components/buttons/invite_management_buttons/accept_invite_btn.dart';
import 'package:expensee/components/buttons/invite_management_buttons/decline_invite_btn.dart';
import 'package:expensee/components/dialogs/default_success_dialog.dart';
import 'package:expensee/components/invites/invitation.dart';
import 'package:expensee/components/nav_bars/default_bottom_bar.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/models/invitation_model.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//TODO - View declined invites, probably dont need to view accepted.

class InviteManagementScreen extends StatefulWidget {
  static const routeName = "/manage-invites";
  final String email;
  final String status;

  const InviteManagementScreen(
      {super.key, required this.email, required this.status});

  @override
  State<StatefulWidget> createState() => _InviteManagementScreenState();
}

class _InviteManagementScreenState extends State<InviteManagementScreen> {
  List<(InvitationItem invite, String boardName, String role)> invites = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: viewInvitesAppBarTitle),
        leading: null,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const DefaultBottomAppBar(),
      body: _buildInvitesScreen(context),
    );
  }

// Gets all pending invites for a user
  Future<List<(InvitationItem invitation, String boardName, String role)>>
      _fetchPendingInvites(GroupMemberProvider groupMemberProvider,
          BoardProvider boardProvider, String email) async {
    final pendingInvites = await groupMemberProvider.getInvites(email, "sent");

    List<(InvitationItem invitation, String boardName, String role)>
        invitesWithBoardNames = [];

    if (pendingInvites.isNotEmpty) {
      for (Invitation invite in pendingInvites) {
        final boardName = await boardProvider.getBoardName(invite.boardId);
        final inviteItem = InvitationItem(invitation: invite);
        final role = invite.role.toString().split(".").last;
        invitesWithBoardNames.add((inviteItem, boardName, role));
      }
    }
    if (mounted) {
      setState(() {
        invites = invitesWithBoardNames;
      });
    }
    return invitesWithBoardNames;
  }

// Gets all declined invites for a user
  Future<List<(InvitationItem invitation, String boardName, String role)>>
      _fetchDeclinedInvites(GroupMemberProvider groupMemberProvider,
          BoardProvider boardProvider, String email) async {
    final declinedInvites =
        await groupMemberProvider.getInvites(email, "declined");

    List<(InvitationItem invitation, String boardName, String role)>
        invitesWithBoardNames = [];

    if (declinedInvites.isNotEmpty) {
      for (Invitation invite in declinedInvites) {
        final boardName = await boardProvider.getBoardName(invite.boardId);
        final inviteItem = InvitationItem(invitation: invite);
        final role = invite.role.toString().split(".").last;
        invitesWithBoardNames.add((inviteItem, boardName, role));
      }
      if (mounted) {
        setState(() {
          invites = invitesWithBoardNames;
        });
      }
    }
    return invitesWithBoardNames;
  }

// Gets all accepted invites for a uer
  Future<List<(InvitationItem invitation, String boardName, String role)>>
      _fetchAcceptedInvites(GroupMemberProvider groupMemberProvider,
          BoardProvider boardProvider, String email) async {
    final pendingInvites =
        await groupMemberProvider.getInvites(email, "accepted");

    List<(InvitationItem invitation, String boardName, String role)>
        invitesWithBoardNames = [];

    if (pendingInvites.isNotEmpty) {
      for (Invitation invite in pendingInvites) {
        final boardName = await boardProvider.getBoardName(invite.boardId);
        final inviteItem = InvitationItem(invitation: invite);
        final role = invite.role.toString().split(".").last;
        invitesWithBoardNames.add((inviteItem, boardName, role));
      }
      if (mounted) {
        setState(() {
          invites = invitesWithBoardNames;
        });
      }
    }
    return invitesWithBoardNames;
  }

  // renders loading bar view
  Widget _renderProgressBar(BuildContext context) {
    return (loading
        ? const CircularProgressIndicator(
            value: null,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          )
        : Container());
  }

// renders main screen
  Widget _buildInvitesScreen(BuildContext context) {
    return Column(
      children: [
        _renderProgressBar(context),
        Expanded(child: _renderListView(context)),
        const Padding(
          padding: EdgeInsets.all(12.0),
        ),
      ],
    );
  }

// helper method for rendering main screen
  Widget _renderListView(BuildContext context) {
    return ListView.builder(
        itemCount: invites.length, itemBuilder: _listViewItemBuilder);
  }

// builds out each individual invite widget to display into a rendered list
  Widget _listViewItemBuilder(BuildContext context, int index) {
    final inviteItem = invites[index];

    return Column(
      children: [
        _renderInviteView(
            inviteItem.$1.invitation, inviteItem.$2, inviteItem.$3),
      ],
    );
  }

// renders an invite into a displayable widget format
  Widget _renderInviteView(Invitation invite, String boardName, String role) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(
                    "Board: $boardName")), // Directly display the board name
            Expanded(
              child: Text("Role: ${role.toUpperCase()}}"),
            ),
            AcceptInviteButton(
                text: acceptBtnText,
                imagePath: acceptInviteImagePath,
                onPressed: () async => _acceptInvite(invite)),
            DeclineInviteButton(
                text: declineBtnText,
                imagePath: declineInviteImagePath,
                onPressed: () async => _declineInvite(invite))
          ],
        ),
      ),
    );
  }

// accepts an invite for current user
  Future<void> _acceptInvite(Invitation invite) async {
    await Provider.of<GroupMemberProvider>(context, listen: false)
        .acceptInvite(invite.token);
    await _loadData();
    await Provider.of<GroupMemberProvider>(context, listen: false)
        .notifyUserAdded(invite.boardId, invite.invitedEmail);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DefaultSuccessDialog(successMessage: "Invite accepted");
        });
  }

// decline an invite for current user
  Future<void> _declineInvite(Invitation invite) async {
    await Provider.of<GroupMemberProvider>(context, listen: false)
        .declineInvite(invite.token);
    await _loadData();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DefaultSuccessDialog(successMessage: "Invite declined");
        });
  }

// method used to load in invites, initially and after accept/decline
  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
      });

      final groupMemberProvider =
          Provider.of<GroupMemberProvider>(context, listen: false);
      final boardProvider = Provider.of<BoardProvider>(context, listen: false);

      try {
        switch (widget.status) {
          case "sent":
            await _fetchPendingInvites(
                groupMemberProvider, boardProvider, widget.email);
            break;
          case "declined":
            await _fetchDeclinedInvites(
                groupMemberProvider, boardProvider, widget.email);
          case "accepted":
            await _fetchPendingInvites(
                groupMemberProvider, boardProvider, widget.email);
            break;
        }
      } catch (e) {
        print("Error: $e\n Failed to load invites");
      } finally {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    }
  }
}
