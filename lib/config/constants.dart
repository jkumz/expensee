import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// LOG IN PAGE CONSTANTS

// LOG IN PAGE - Button text
const signInWithGoogleButtonText = "Sign in with Google";
const signInWithPasswordButtonText = "Sign in";
const signInWithMagicLinkButtonText = "Sign in with Magic Link";
const signUpButtonText = "Sign Up";
const loadingText = "Loading...";

// LOG IN PAGE - Controllers
const emailControllerDecoration = InputDecoration(labelText: "Email");
const passwordControllerDecoration = InputDecoration(labelText: "Password");

// LOG IN PAGE - SnackBar text
const magicLinkPopupText =
    "We've sent you a passwordless login link to your email!";
const signInSuccessText = "Signed in!";
const confirmationEmailPopUpText =
    Text("Please sign up your confirmation in your email.");
const unexpectedErrorText = Text("Unexpected error occured...");

// LOG IN PAGE - Explanatory text
const signInExplanationText =
    'To use our passwordless log in, put in your email and press the Send Magic Link button.\n\nAlternatively, you can sign up with your email of choice or log in with your Google/Apple account.';
