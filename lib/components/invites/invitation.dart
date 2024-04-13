import 'package:expensee/components/buttons/invite_management_buttons/accept_invite_btn.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/models/invitation_model.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InvitationItem extends StatefulWidget {
  final Invitation invitation;

  const InvitationItem({super.key, required this.invitation});

  @override
  State<StatefulWidget> createState() => _InvitationItemState();
}

class _InvitationItemState extends State<InvitationItem> {
  Future<String> _getBoardName(boardId) async {
    return await Provider.of<BoardProvider>(context, listen: false)
        .getBoardName(widget.invitation.boardId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(expenseItemPadding),
      child: Row(
        children: [
          // Use a FutureBuilder to wait for the _getBoardName future to complete
          Expanded(
            flex: expenseItemFlex,
            child: FutureBuilder<String>(
              future: _getBoardName(widget.invitation.boardId),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a placeholder or loading indicator while the future is unresolved
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Handle error cases
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Once the future is complete, build the UI with the data
                  return Text(
                    snapshot.data ?? 'Unknown board',
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
