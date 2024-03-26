import 'package:expensee/models/group_member/group_member.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDropdownMenu extends StatefulWidget {
  final Function(String) onUserSelected;
  final bool isAdmin;
  final String boardId;

  const UserDropdownMenu({
    Key? key,
    required this.onUserSelected,
    required this.isAdmin,
    required this.boardId,
  }) : super(key: key);

  @override
  _UserDropdownMenuState createState() => _UserDropdownMenuState();
}

class _UserDropdownMenuState extends State<UserDropdownMenu> {
  late Future<List<GroupMember>> _memberListFuture;
  // ignore: avoid_init_to_null
  String? selectedEmail = null;

  @override
  void initState() {
    super.initState();
    _memberListFuture = Provider.of<GroupMemberProvider>(context, listen: false)
        .getGroupMembers(widget.boardId, widget.isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GroupMember>>(
      future: _memberListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final memberList = snapshot.data!;
          return DropdownButton<String>(
            items: memberList.map((GroupMember member) {
              final email = member.email;
              return DropdownMenuItem<String>(
                value: email,
                child: Text(email),
              );
            }).toList(),
            value: memberList.isNotEmpty
                ? (selectedEmail ?? memberList.first.email)
                : null,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedEmail = newValue;
                });
                widget.onUserSelected(newValue);
              }
            },
          );
        }
      },
    );
  }
}
