import 'package:expensee/components/buttons/invite_management_buttons/accept_invite_btn.dart';
import 'package:expensee/components/buttons/invite_management_buttons/decline_invite_btn.dart';
import 'package:expensee/components/invites/invitation.dart';
import 'package:expensee/components/nav_bars/default_bottom_bar.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/models/invitation_model.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// We need:
// A method for refreshing invites for a member - done
// A method for fetching all invites for a member - done
// A method for building out the invite display (only non accepted/declined)
//    - Lists board name, accpet/decline button - done
// A method for accepting invite + pop up
// A method for declining invite + refresh

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
  List<(InvitationItem invite, String boardName)> invites = [];
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
      appBar: AppBar(title: viewInvitesAppBarTitle),
      bottomNavigationBar: const DefaultBottomAppBar(),
      body: _buildInvitesScreen(context),
    );
  }

  Future<List<(InvitationItem invitation, String boardName)>>
      _fetchAcceptedInvites(GroupMemberProvider groupMemberProvider,
          BoardProvider boardProvider, String email) async {
    final pendingInvites = await groupMemberProvider.getInvites(email, "sent");

    List<(InvitationItem invitation, String boardName)> invitesWithBoardNames =
        [];

    if (pendingInvites.isNotEmpty) {
      for (Invitation invite in pendingInvites) {
        final boardName = await boardProvider.getBoardName(invite.boardId);
        final inviteItem = InvitationItem(invitation: invite);
        invitesWithBoardNames.add((inviteItem, boardName));
      }

      if (mounted) {
        setState(() {
          invites = invitesWithBoardNames;
        });
      }
    }
    return invitesWithBoardNames;
  }

  Future<List<(InvitationItem invitation, String boardName)>>
      _fetchDeclinedInvites(GroupMemberProvider groupMemberProvider,
          BoardProvider boardProvider, String email) async {
    final declinedInvites =
        await groupMemberProvider.getInvites(email, "declined");

    List<(InvitationItem invitation, String boardName)> invitesWithBoardNames =
        [];

    if (declinedInvites.isNotEmpty) {
      for (Invitation invite in declinedInvites) {
        final boardName = await boardProvider.getBoardName(invite.boardId);
        final inviteItem = InvitationItem(invitation: invite);
        invitesWithBoardNames.add((inviteItem, boardName));
      }
      if (mounted) {
        setState(() {
          invites = invitesWithBoardNames;
        });
      }
    }
    return invitesWithBoardNames;
  }

  Future<List<(InvitationItem invitation, String boardName)>>
      _fetchPendingInvites(GroupMemberProvider groupMemberProvider,
          BoardProvider boardProvider, String email) async {
    final pendingInvites =
        await groupMemberProvider.getInvites(email, "accepted");

    List<(InvitationItem invitation, String boardName)> invitesWithBoardNames =
        [];

    if (pendingInvites.isNotEmpty) {
      for (Invitation invite in pendingInvites) {
        final boardName = await boardProvider.getBoardName(invite.boardId);
        final inviteItem = InvitationItem(invitation: invite);
        invitesWithBoardNames.add((inviteItem, boardName));
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

  Widget _renderListView(BuildContext context) {
    return ListView.builder(
        itemCount: invites.length, itemBuilder: _listViewItemBuilder);
  }

  Widget _listViewItemBuilder(BuildContext context, int index) {
    final inviteItem = invites[index];

    return Column(
      children: [
        _renderInviteView(inviteItem.$1.invitation, inviteItem.$2),
      ],
    );
  }

  Widget _renderInviteView(Invitation invite, String boardName) {
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

  Future<void> _acceptInvite(invite) async {}

  Future<void> _declineInvite(invite) async {}

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
      });

      final groupMemberProvider =
          Provider.of<GroupMemberProvider>(context, listen: false);
      final boardProvider = Provider.of<BoardProvider>(context, listen: false);

      switch (widget.status) {
        case "sent":
          await _fetchAcceptedInvites(
              groupMemberProvider, boardProvider, widget.email);
          break;
        case "declined":
          await _fetchDeclinedInvites(
              groupMemberProvider, boardProvider, widget.email);
        case "accepted":
          await _fetchAcceptedInvites(
              groupMemberProvider, boardProvider, widget.email);
          break;
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _refreshExpenses() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    final groupMemberProvider =
        Provider.of<GroupMemberProvider>(context, listen: false);
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    switch (widget.status) {
      case "sent":
        await _fetchAcceptedInvites(
            groupMemberProvider, boardProvider, widget.email);
        break;
      case "declined":
        await _fetchDeclinedInvites(
            groupMemberProvider, boardProvider, widget.email);
      case "accepted":
        await _fetchAcceptedInvites(
            groupMemberProvider, boardProvider, widget.email);
        break;
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
