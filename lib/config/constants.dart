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

// SIGN UP PAGE
const signUpExplanationText =
    "To sign up with your email, please provide an email and password then verify account creation in your inbox.";

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
const massEmailImagePath = "assets/images/email.png";
const searchImagePath = "assets/images/search.png";
const calendarImagePath = "assets/images/calendar.png";
const categoryImagePath = "assets/images/category.png";
const userSelectionImagePath = "assets/images/users.png";
const resetImagePath = "assets/images/reset.png";
const addReceiptImagePath = "assets/images/receipt.png";
const saveImagePath = "assets/images/save.png";
const viewReceiptImagePath = "assets/images/view-receipt.png";
const binImagePath = "assets/images/bin.png";

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

// EXPENSE BOARD CONSTANTS

const boardCreationSuccessMessage = "Expense board created";
const boardCreationFailureMessage = "Failed to create board";

const viewSoloExpenseBoardsBtnText = "View your Expense Boards";
const viewGroupExpenseBoardsBtnText = "View Group Expense Boards";
const viewInvitesBtnText = "Manage Invites";
const enterBoardName = "Please enter a board name";
const createBoardText = Text("Create board");
const groupBoardQuestionText = Text("Group board?");

// EXPENSE BOARD SETTINGS SCREEN CONSTANTS

const boardSettingsAppBarTitle = "Board Settings";
const renameText = Text("Rename");

// EXPENSE LIST CONSTANTS

const noExpensesText = "No expenses to display";
const addUserText = "Invite User";
const removeUserText = "Remove User";
const manageUserRolesText = "Manage User Roles";
const renameBoardText = "Rename Board";
const passOwnershipText = "Transfer Ownership";
const delBoardText = "Delete Board";
const massEmailText = "Send Email Notification";
const searchBoardText = "Filter Expenses";
const downloadReceiptsText = "Download Receipts";

const boldedExpenseTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

// EXPENSE CREATION SCREEN

const createExpenseBtnText = Text("Create Expense");
const modifyExpenseBtnText = Text("Modify Expense");
const categoryLength = 17;
const expenseDescLength = 46;
const invalidDateText = "Date must be in YYYY-MM-DD format";
const invalidValueText =
    "Invalid format. Please enter a balance in X.XX format";
const blankValueText = "Please enter a balance in X.XX format";

// INVITE MANAGEMENT CONSTANTS

const viewInvitesAppBarTitle = Text("Manage Board Invites");
const acceptBtnText = "ACCEPT";
const declineBtnText = "DECLINE";
String inviteSentText(String email) => "Invite sent to $email";
const sendInviteText = Text("Send invite");

// POP UP MESSAGES

const deleteBoardMessage =
    "Are you sure you wish to delete this board? Unless you've backed the data up, all of it will be permanently lost.";
const deleteExpenseError =
    "Unless you're an Admin, you can only delete expenses you created.";
const modifyExpenseError =
    "Unless you're an Admin, you can only modify expenses you created.";
const addReceiptError =
    "Unless you're an Admin, you can only add receipts to expenses you created.";
const noStoragePerms = "Storage permissions are needed to save this receipt";
const askToDeleteReceipt =
    Text('Are you sure you want to delete this receipt?');
const askToDeleteReceiptTitle = Text('Confirm Delete');
const boardNameTooLongError = Text('Name must be 30 characters or less.');
const permsErrorTitle = "Permission Error";
const selectCategoriesPopupText = Text('Select Categories');
const selectDateRange = Text('Select Range');
const receiptSaveFail = "Failed to save receipt";

// PERMS TEXT
const permsChangeSuccessTitle = "Permissions updated";
String permsChangedMessage(String email, String role) =>
    "$email permissions changed to $role";
String failedToChangePermsMsg(String email) =>
    "Failed to change permission for $email";

// GENERIC CONSTANTS
const noMembers = Center(child: Text("No members to display"));
const noExpenses = Center(
  child: Text("No expenses to display"),
);
const saveText = Text('Save');
const deleteText = Text('Delete');
const okText = Text('OK');
const closeText = Text('Close');
const cancelText = Text('Cancel');
const insertEmailText = "Please enter an email address";
const successText = "Success";
const errorText = "Error";
const failText = "Failed";
const noEmailText = Text("No email selected");
const selectUserText = "Select a user";
const transferOwnershipText = Text("Transfer ownership");
const selectOwnerText = Text(
  "Select a new owner",
  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
);
const unAuthorizedAccessText = Text(
  "UNAUTHORIZED ACCESS",
  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
);

// MASS EMAIL
const adminEmailSentText =
    "Your emails have been sent to the admin mailing list";
const massEmailSentText =
    "Your emails have been sent to everyone in this board.";
const noRecipientsTitle = "Empty Mailing List";
const noRecipientsError = "Failed to retrieve emails...";
const adminEmailFailed =
    "Your emails have failed to send to the admin mailing list";
const massEmailFailed = "Your emails failed to send to everyone in this board.";
const emailSubjectText = "Enter email subject";
const emailBodyText = "Enter email body";
const sentToAdminsSuccess = Text("Send to Admins Only");
const sendEmailText = Text("Send Email");
