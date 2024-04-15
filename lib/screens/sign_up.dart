// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:expensee/components/buttons/custom_callback_button.dart';
import 'package:expensee/config/constants.dart';
import 'package:expensee/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUp extends StatefulWidget {
  static const String routeName = "/sign-up";

  const SignUp({super.key});

  @override
  createState() => _SignUpState();

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

class _SignUpState extends State<SignUp> {
  final _appBarTitle = const Text("Sign Up");

  final authCallback = '${dotenv.env['PROJECT_SCHEMA']}://login-callback/';

  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();

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
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _appBarTitle),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text(signUpExplanationText),
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
            obscureText: true,
          ),
          const SizedBox(height: 18), // to add space
          CustomCallbackButton(const Text(signUpButtonText), _emailSignUp),
        ],
      ),
    );
  }
}
