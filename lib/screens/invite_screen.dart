import 'package:expensee/models/invitation_model.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InvitationScreen extends StatefulWidget {
  final String invitationToken;

  const InvitationScreen({Key? key, required this.invitationToken})
      : super(key: key);

  @override
  _InvitationScreenState createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  Invitation? _invitation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvitationDetails(widget.invitationToken);
  }

  Future<void> fetchInvitationDetails(String token) async {
    // Simulate fetching invitation details from Supabase or your backend
    // This is where you would make the API call to get the invitation details using the token
    // For now, let's mock this with a dummy invitation
    setState(() async {
      _invitation =
          await Provider.of<GroupMemberProvider>(context, listen: false)
              .getInvite(token);
    });
  }

  void acceptInvitation() {
    // Logic to accept the invitation, e.g., make an API call to add the user to the board
    // Then navigate to the board screen
    Navigator.of(context)
        .pushReplacementNamed('/boardScreen', arguments: _invitation?.boardId);
  }

  void declineInvitation() {
    // Logic to decline the invitation if necessary, e.g., notify the backend
    // Then navigate back to the home page
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Board Invitation')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                    'You have been invited to join the board "${_invitation?.boardId}" by ${_invitation?.inviterId}.',
                    textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: acceptInvitation,
                  child: Text('Accept Invite'),
                ),
                ElevatedButton(
                  onPressed: declineInvitation,
                  child: Text('Decline Invite'),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                ),
              ],
            ),
    );
  }
}