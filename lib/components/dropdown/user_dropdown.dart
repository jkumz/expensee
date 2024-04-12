import 'package:expensee/config/constants.dart';
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
  createState() => _UserDropdownMenuState();
}

class _UserDropdownMenuState extends State<UserDropdownMenu> {
  late Future<List<GroupMember>> _memberListFuture;
  String? selectedEmail; // Start with no email selected

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
            hint: const Text(
                selectUserText), // Used when no item is selected (value is null)
            value: selectedEmail, // Value is null until an item is selected
            items: memberList.map((GroupMember member) {
              return DropdownMenuItem<String>(
                value: member.email,
                child: Text(member.email),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null && mounted) {
                setState(() {
                  selectedEmail = newValue;
                  widget.onUserSelected(newValue);
                });
              }
            },
            isExpanded: true, // Ensure it occupies the full width
          );
        }
      },
    );
  }
}
