// import 'package:expensee/config/constants.dart';
// import 'package:expensee/providers/board_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';

// import 'package:expensee/components/forms/create_expense_board_form.dart';

// class MockBoardProvider extends Mock implements BoardProvider {}

// void main() {
//   group('CreateExpenseBoardForm Tests', () {
//     MockBoardProvider mockBoardProvider = MockBoardProvider();

//     Widget makeTestableWidget() => MaterialApp(
//           home: ChangeNotifierProvider<BoardProvider>(
//             create: (_) => mockBoardProvider,
//             child: const CreateExpenseBoardForm(),
//           ),
//         );

//     testWidgets('Creating an expense board successfully shows success dialog',
//         (WidgetTester tester) async {
//       when(mockBoardProvider.createBoard(any)).thenAnswer((_) async => true);

//       await tester.pumpWidget(makeTestableWidget());
//       await tester.enterText(find.byType(TextFormField).first, 'New Board');
//       await tester.enterText(find.byType(TextFormField).at(1), '100.00');
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump(); // React to button press

//       // Verify that the success dialog is shown
//       expect(find.text(boardCreationSuccessMessage), findsOneWidget);
//     });

//     testWidgets('Failing to create an expense board shows error dialog',
//         (WidgetTester tester) async {
//       when(mockBoardProvider.createBoard(any)).thenAnswer((_) async => false);

//       await tester.pumpWidget(makeTestableWidget());
//       await tester.enterText(find.byType(TextFormField).first, 'New Board');
//       await tester.enterText(find.byType(TextFormField).at(1), '100.00');
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump(); // React to button press

//       // Verify that the error dialog is shown
//       expect(find.text(boardCreationFailureMessage), findsOneWidget);
//     });
//   });
// }
