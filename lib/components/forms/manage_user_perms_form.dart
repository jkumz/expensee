import 'package:expensee/components/dropdown/roles_dropdown.dart';
import 'package:expensee/enums/roles.dart';
import 'package:expensee/models/group_member/group_member.dart';
import 'package:expensee/providers/g_member_provider.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart' as Provider;

class ManageUserPermsForm extends StatefulWidget {
  const ManageUserPermsForm(
      {super.key, required this.boardId, required this.role});
  final String boardId;
  final String role;

  @override
  State<StatefulWidget> createState() => _ManageUserPermsFormState();
}

class _ManageUserPermsFormState extends State<ManageUserPermsForm> {
  final _formKey = GlobalKey<FormState>(); // unique id
  String _selectedEmail = "@";
  Roles _selectedRole = Roles.shareholder;

  // handle form submission
  // TODO - fix navigation
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // save current state of the form

      bool removed = await _changeUserRole(_selectedEmail, _selectedRole);
      // Build context may have been removed from widget tree by the time async method
      // finishes. We check if its mounted before trying to use it to prevent a crash.
      if (!mounted) return;
      if (!removed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to change permission for $_selectedEmail"),
        ));
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "$_selectedEmail permissions changed to ${_selectedRole.toFormattedString()}"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: Provider.Provider.of<GroupMemberProvider>(context, listen: false)
          .getGroupMembers(widget.boardId, false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the future to complete
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle the error case
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Build the form with the owner's additional options
          return _buildForm(context, snapshot.data);
        } else {
          // Build the form without the owner's additional options
          return const Center(
            child: Text("No members to display"),
          );
        }
      },
    );
  }

// TODO - text styling, consts moved to const file
  Widget _buildForm(BuildContext context, List<dynamic>? memberList) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            DataTable(
              columnSpacing: 30,
              columns: _generateTableColumns(),
              rows: _generateTableRows(memberList),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _changeUserRole(String email, Roles newRole) async {
    return await Provider.Provider.of<GroupMemberProvider>(context,
            listen: false)
        .updateRole(widget.boardId, email, newRole);
  }

  List<DataColumn> _generateTableColumns() {
    return const [
      DataColumn(label: Text("Email")),
      DataColumn(label: Text("Role")),
    ];
  }

  List<DataRow> _generateTableRows(List<dynamic>? memberList) {
    return List<DataRow>.generate(
      memberList!.length,
      (index) {
        GroupMember member = memberList[index];
        return DataRow(
          cells: [
            DataCell(Text(member.email)),
            DataCell(
              PopupMenuButton<Roles>(
                onSelected: (Roles selectedRole) {
                  setState(() {
                    member.role = selectedRole;
                    _selectedRole = selectedRole;
                    _selectedEmail = member.email;
                  });
                  _submit();
                },
                itemBuilder: _rolesItemBuilder,
                child: _tableRow(member),
              ),
            )
          ],
        );
      },
    );
  }

  List<PopupMenuEntry<Roles>> _rolesItemBuilder(BuildContext context) {
    return Roles.values
        .where((Roles role) => role != Roles.owner)
        .map((Roles role) {
      return PopupMenuItem<Roles>(
        value: role,
        child: Text(role.toFormattedString()),
      );
    }).toList();
  }

  Row _tableRow(GroupMember member) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(member.role.toFormattedString()),
        const Icon(Icons.arrow_drop_down),
      ],
    );
  }
}
