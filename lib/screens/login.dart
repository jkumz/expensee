import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensee/main.dart';

// TODO - set up log in via Gmail & FB

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
        emailRedirectTo: kIsWeb
            ? null
            : '${dotenv.env['SUPABASE_PROJECT_SCHEMA']}://login-callback/',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "We've sent you a passwordless login link to your email!")),
        );
        _emailController.clear();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
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

  Future<void> _signInWithPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await supabase.auth.signInWithPassword(
          password: _passwordController.text.trim(),
          email: _emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signed in!")),
        );
        _emailController.clear();
        _passwordController.clear();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
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
      await supabase.auth.signInWithOAuth(Provider.google,
          redirectTo: dotenv.env["SUPABASE_AUTH_CALLBACK"]);
    } catch (e) {
      print("todo");
    }
  }

  Future<void> _signInWithApple() async {
    try {
      await supabase.auth.signInWithOAuth(Provider.apple,
          redirectTo: dotenv.env["SUPABASE_AUTH_CALLBACK"]);
    } catch (e) {
      print("todo");
    }
  }

  Future<void> _emailSignUp() async {
    await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please sign up your confirmation in your email.")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text(
              'To use our passwordless log in, put in your email and press the Send Magic Link button.'),
          const SizedBox(
            height: 10,
          ),
          const Text(
              "Alternatively, you can sign up with your email of choice or log in with your Google/Apple account."),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 18), // to add space
          ProvideCallbackButton(Text(_isLoading ? 'Loading' : 'Sign In'),
              _isLoading ? null : _signInWithPassword),
          const SizedBox(height: 18), // to add space
          ProvideCallbackButton(
              Text(_isLoading ? 'Loading' : 'Sign in with Google'),
              _isLoading ? null : _signInWithGoogle),
          const SizedBox(height: 18), // to add space
          ProvideCallbackButton(
              Text(_isLoading ? 'Loading' : 'Sign in with Apple'),
              _isLoading ? null : _signInWithApple),
          const SizedBox(height: 18), // to add space
          ProvideCallbackButton(Text(_isLoading ? 'Loading' : 'Sign Up'),
              _isLoading ? null : _emailSignUp),
          const SizedBox(height: 18), // to add space
          MagicLinkButton(
            Text(_isLoading ? 'Loading' : 'Send Magic Link'),
            _isLoading ? null : _signInWithMagicLink,
          ),
        ],
      ),
    );
  }
}

class MagicLinkButton extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final Color? textColour;
  final Color? backgroundColour;

  const MagicLinkButton(this.child, this.onTap,
      {Key? key, this.textColour, this.backgroundColour});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap != null
          ? () {
              onTap!();
            }
          : null,
      child: child,
      style: ElevatedButton.styleFrom(
          foregroundColor: (textColour ?? Colors.white),
          backgroundColor:
              (backgroundColour ?? const Color.fromARGB(255, 170, 76, 175)),
          elevation: 1,
          textStyle: TextStyle(/*TODO make custom text styles*/)),
    );
  }
}

class ProvideCallbackButton extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final Color? textColour;
  final Color? backgroundColour;

  const ProvideCallbackButton(this.child, this.onTap,
      {Key? key, this.textColour, this.backgroundColour});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap != null
          ? () {
              onTap!(); // ! operator basically says its guaranteed to not be null
            }
          : null,
      child: child,
      style: ElevatedButton.styleFrom(
          foregroundColor: (textColour ?? Colors.white),
          backgroundColor:
              (backgroundColour ?? const Color.fromARGB(255, 170, 76, 175)),
          elevation: 1,
          textStyle: TextStyle(/*TODO make custom text styles*/)),
    );
  }
}
