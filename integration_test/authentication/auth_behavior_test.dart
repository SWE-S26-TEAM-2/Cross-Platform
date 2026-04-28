import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// AUTH BEHAVIOR TESTS
/// 
/// Coverage: AUTH-014, AUTH-015, Critical #3 (logout)
/// These tests verify expected user navigation flows within auth screens.
/// Existing authentication_test.dart remains the smoke baseline.

void main() {
  ensureBinding();

  group('auth behavior', () {
    testWidgets('user navigates back from signup to welcome screen', (
      tester,
    ) async {
      // AUTH-014: Back navigation from signup
      await launchApp(tester);

      await tapAndSettle(tester, actionButton('Create an account'));
      await pumpUntilVisible(tester, find.text('Create your account'));

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Where artists\n& fans connect.'), findsOneWidget);
      expect(actionButton('Create an account'), findsOneWidget);
      expect(outlinedActionButton('Log in'), findsOneWidget);
    });

    testWidgets('user navigates back from login to welcome screen', (
      tester,
    ) async {
      // AUTH-015: Back navigation from login
      await launchApp(tester);

      await tapAndSettle(tester, outlinedActionButton('Log in'));
      await pumpUntilVisible(tester, find.text('Welcome back'));

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Where artists\n& fans connect.'), findsOneWidget);
      expect(actionButton('Create an account'), findsOneWidget);
      expect(outlinedActionButton('Log in'), findsOneWidget);
    });

    testWidgets('user navigates signup -> back -> login -> back consistently', (
      tester,
    ) async {
      // Verifies navigator stack doesn't accumulate
      await launchApp(tester);

      // Cycle 1
      await tapAndSettle(tester, actionButton('Create an account'));
      await pumpUntilVisible(tester, find.text('Create your account'));
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Cycle 2
      await tapAndSettle(tester, outlinedActionButton('Log in'));
      await pumpUntilVisible(tester, find.text('Welcome back'));
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Cycle 3
      await tapAndSettle(tester, actionButton('Create an account'));
      await pumpUntilVisible(tester, find.text('Create your account'));
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Final state: back at welcome
      expect(actionButton('Create an account'), findsOneWidget);
      expect(outlinedActionButton('Log in'), findsOneWidget);
    });

    // TODO: Logout test — UI logout button not yet implemented
    // When available, this test should verify:
    // 1. User logs in successfully
    // 2. User taps logout (location TBD: Library settings? Profile?)
    // 3. User returns to welcome screen
    // 4. Protected screens no longer accessible without re-login
    //
    // testWidgets('user logs out and returns to welcome screen', (tester) async {
    //   await launchApp(tester);
    //   await loginAsSeededUser(tester);
    //   
    //   // Navigate to logout location (TBD)
    //   // await tapAndSettle(tester, find.text('Log out'));
    //   
    //   // expect(find.text('Where artists\n& fans connect.'), findsOneWidget);
    // });
  });
}
