import 'package:flutter/material.dart';

// Generic class for giving confirmation alerts
class DialogHelper {
  static Future<bool> showConfirmationDialog(
      BuildContext context, String message) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context)
                  .pop(false), // Passing false when "No" is pressed.
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context)
                  .pop(true), // Passing true when "Yes" is pressed.
            ),
          ],
        );
      },
    );
    // If the dialog is dismissed by tapping outside of it, it returns null.
    // Treat this as a "No" response (i.e., user does not confirm).
    return confirmed ?? false;
  }
}
