import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:expensee/main.dart';
import 'dart:async';

// DeepLinkHandler class manages the listening and handling of deep links.
class DeepLinkHandler {
  // Singleton pattern
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();

  // StreamSubscription to listen to the incoming deep links.
  StreamSubscription? _sub;

  // Initialize the deep link listener and handle any incoming links.
  void initDeepLinkListener(BuildContext context) {
    // Subscribing to the stream of incoming links.
    _sub = linkStream.listen((String? link) {
      // This block is called whenever a new link is opened in the app.
      if (link != null) {
        _handleLink(link, context);
      }
    }, onError: (err) {
      // TODO - error handling
    });
  }

  // Private method to handle the link and execute logic based on the link received.
  void _handleLink(String link, BuildContext context) {
    Uri uri = Uri.parse(link);
    // Checking if the incoming link is an invite link.
    if (uri.pathSegments.contains('invite')) {
      // Extracting the 'token' query parameter from the Uri object.
      String? token = uri.queryParameters['token'];
      if (token != null) {
        // If a token is present, navigate to screen accordingly.
        // Scheduling a callback to run in the next frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Navigating to the 'accept-invitation' route with the token as an argument.
          if (supabase.auth.currentSession != null) {
            Navigator.of(context)
                .pushReplacementNamed('/accept-invitation', arguments: token);
          } else {
            Navigator.of(context).pushNamed('/login', arguments: {
              'followUpToken': token,
              'followUpRoute': '/accept-invitation'
            });
          }
        });
      }
    }
  }

  // Method to dispose of the stream subscription when it is no longer needed.
  void dispose() {
    _sub?.cancel();
  }
}
