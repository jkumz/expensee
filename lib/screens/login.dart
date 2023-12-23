import 'dart:async';

import 'package:expensee/components/elevated_buttons/authentication_buttons/sign_in_with_google_button.dart';
import 'package:expensee/components/elevated_buttons/authentication_buttons/sign_in_with_password_button.dart';
import 'package:expensee/components/elevated_buttons/authentication_buttons/magic_link_button.dart';
import 'package:expensee/config/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensee/main.dart';
import 'package:expensee/components/elevated_buttons/custom_callback_button.dart';

class Login extends StatefulWidget {
  static const String routeName = "/login";

  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  bool _redirecting = false;
  final _appBarTitle = const Text("Log In");

  final authCallback =
      '${dotenv.env['SUPABASE_PROJECT_SCHEMA']}://login-callback/';

  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signInWithMagicLink() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo: kIsWeb ? null : authCallback,
      );
      if (mounted) {
        displaySignInSuccess();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
          content: unexpectedErrorText,
          backgroundColor: Theme.of(context).colorScheme.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await supabase.auth.signInWithPassword(
          password: _passwordController.text.trim(),
          email: _emailController.text.trim());

      if (mounted) {
        displaySignInSuccess();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: unexpectedErrorText,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await supabase.auth
          .signInWithOAuth(Provider.google, redirectTo: authCallback);

      if (mounted) {
        displaySignInSuccess();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: unexpectedErrorText,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// TO DO - implement this in Supabase back end - need to make Apple dev profile
// TO DO - refactor both OAuth sign in methods into one method, taking provider as param
  Future<void> _signInWithApple() async {
    try {
      await supabase.auth
          .signInWithOAuth(Provider.apple, redirectTo: authCallback);

      if (mounted) {
        displaySignInSuccess();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: unexpectedErrorText,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _emailSignUp() async {
    await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: confirmationEmailPopUpText),
      );
      _emailController.clear();
    }
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  void displaySignInSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(signInSuccessText)),
    );
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _appBarTitle),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text(signInExplanationText),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _emailController,
            decoration: emailControllerDecoration,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            decoration: passwordControllerDecoration,
          ),
          const SizedBox(height: 18), // to add space
          SignInWithPasswordButton(
              Text(_isLoading ? loadingText : signInWithPasswordButtonText),
              _isLoading ? null : _signInWithPassword),
          const SizedBox(height: 18), // to add space
          SignInWithGoogleButton(
              Text(_isLoading ? loadingText : signInWithGoogleButtonText),
              _isLoading ? null : _signInWithGoogle),
          const SizedBox(height: 18), // to add space
          MagicLinkButton(
            Text(_isLoading ? loadingText : signInWithMagicLinkButtonText),
            _isLoading ? null : _signInWithMagicLink,
          ),
          const SizedBox(height: 18), // to add space
          CustomCallbackButton(
              Text(_isLoading ? loadingText : signUpButtonText),
              _isLoading ? null : _emailSignUp),
        ],
      ),
    );
  }
}
