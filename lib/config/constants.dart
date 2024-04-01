import 'package:flutter/material.dart';

// ROUTES
const loginRoute = "/login";
const homePageRoute = "/home";

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

// ASSET PATHS
const singleBoardImagePath = "assets/images/user.png";
const groupBoardImagePath = "assets/images/people.png";
const addImagePath = "assets/images/add-user.png";
const boardSettingsImagePath = "assets/images/settings.png";
const removeUserFromBoardImagePath = "assets/images/minus.png";
const manageUsersImagePath = "assets/images/manage-roles.png";
const renameBoardImagePath = "assets/images/rename.png";
const viewInvitesImagePath = "assets/images/invitation.png";
const acceptInviteImagePath = "assets/images/accept.png";
const declineInviteImagePath = "assets/images/decline.png";
const deleteImagePath = "assets/images/delete.png";
const transferImagePath = "assets/images/transfer.png";

// EXPENSE BOARD SELECTION CONSATNS

const noBoards = "No boards to display";

// EXPENSE WIDGET CONSTANTS

const expenseItemPadding = 8.0;
const expenseItemFlex = 2;

// EDITABLE EXPENSE WIDGET CONSTANTS

const editableExpenseCategoryLabelText = "Category";
const editableDescriptionLabelText = "Description";
const editableAmountLabelText = "Amount";
const editableDateLabelText = "Date";

// EXPENSE BOARD WIDGET CONSTANTS

const boardCreationSuccessMessage = "Expense board created";
const boardCreationFailureMessage = "Failed to create board";

const viewSoloExpenseBoardsBtnText = "View your Expense Boards";
const viewGroupExpenseBoardsBtnText = "View Group Expense Boards";
const viewInvitesBtnText = "Manage Invites";

// EXPENSE BOARD SETTINGS SCREEN CONSTANTS

const boardSettingsAppBarTitle = "Board Settings";

// EXPENSE LIST CONSTANTS

const noExpensesText = "No expenses to display";
const addUserText = "Invite User";
const removeUserText = "Remove User";
const manageUserRolesText = "Manage User Roles";
const renameBoardText = "Rename Board";
const passOwnershipText = "Transfer Ownership";
const delBoardText = "Delete Board";

const boldedExpenseTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

// EXPENSE CREATION SCREEN

const createExpenseBtnText = Text("Create Expense");
const modifyExpenseBtnText = Text("Modify Expense");
const categoryLength = 17;
const expenseDescLength = 46;

// INVITE MANAGEMENT SCREEN CONSTANTS

const viewInvitesAppBarTitle = Text("Manage Board Invites");
const acceptBtnText = "ACCEPT";
const declineBtnText = "DECLINE";
