import 'package:expensee/enums/roles.dart';
import 'package:flutter/material.dart';

class RolesDropdownMenu extends StatefulWidget {
  final Function(Roles) onRoleChanged;

  const RolesDropdownMenu({super.key, required this.onRoleChanged});

  @override
  createState() => _RolesDropdownMenuState();
}

class _RolesDropdownMenuState extends State<RolesDropdownMenu> {
  final List<Roles> rolesList = [Roles.shareholder, Roles.admin];
  Roles selectedRole = Roles.shareholder; // Set the initial selected role

  @override
  Widget build(BuildContext context) {
    // Convert the Roles enum to a list of strings
    // Build the dropdown menu
    return DropdownButton<Roles>(
      // Map Roles to dropdown items
      items: rolesList.map((Roles role) {
        // Get the role name without the enum class name
        final roleName = role.toString().split('.').last;
        return DropdownMenuItem<Roles>(
          value: role,
          child: Text(roleName.toUpperCase()),
        );
      }).toList(),
      // Set the current selected value
      value: selectedRole,
      // Update the selected role when the user selects a different option
      onChanged: (Roles? newValue) {
        if (newValue != null) {
          if (mounted) {
            setState(() {
              selectedRole = newValue;
              widget.onRoleChanged(newValue);
            });
          }
        }
      },
    );
  }
}
