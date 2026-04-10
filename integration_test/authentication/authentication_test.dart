import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

void main() {
  ensureBinding();

  group('authentication', () {
    testWidgets('launches welcome screen and supports auth entry navigation', (
      tester,
    ) async {
      await launchApp(tester);

      expect(actionButton('Create an account'), findsOneWidget);
      expect(outlinedActionButton('Log in'), findsOneWidget);

      await tapAndSettle(tester, actionButton('Create an account'));
      await pumpUntilVisible(tester, find.text('Create your account'));
      expect(find.text('Create your account'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapAndSettle(tester, outlinedActionButton('Log in'));
      await pumpUntilVisible(tester, find.text('Welcome back'));
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('validates signup form before submission', (tester) async {
      await launchApp(tester);
      await tapAndSettle(tester, actionButton('Create an account'));

      await tapAndSettle(tester, actionButton('Create account'));

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);

      await tester.enterText(authFieldAt(0), 'invalid-email');
      await tester.enterText(authFieldAt(1), 'short');
      await tester.enterText(authFieldAt(2), 'different');
      await tester.pump();

      await tapAndSettle(tester, actionButton('Create account'));

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('creates a mock account and allows login in the same session', (
      tester,
    ) async {
      await launchApp(tester);
      await tapAndSettle(tester, actionButton('Create an account'));

      await tester.enterText(
        textFormFieldByHint('Email address'),
        TestAccounts.newEmail,
      );
      await tester.enterText(
        textFormFieldByHint('Password'),
        TestAccounts.newPassword,
      );
      await tester.enterText(
        textFormFieldByHint('Confirm password'),
        TestAccounts.newPassword,
      );
      await tester.pump();

      await tapAndSettle(tester, actionButton('Create account'));

      await pumpUntilVisible(tester, find.text('Welcome back'));
      expect(find.text('Account created successfully'), findsOneWidget);

      await enterLoginCredentials(
        tester,
        email: TestAccounts.newEmail,
        password: TestAccounts.newPassword,
      );
      await tapAndSettle(tester, actionButton('Log in'));

      await pumpUntilVisible(tester, find.text('Home'));
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Upgrade'), findsOneWidget);
    });

    testWidgets('rejects duplicate signup for an existing mock account', (
      tester,
    ) async {
      await launchApp(tester);
      await tapAndSettle(tester, actionButton('Create an account'));

      await tester.enterText(
        textFormFieldByHint('Email address'),
        TestAccounts.existingEmail,
      );
      await tester.enterText(
        textFormFieldByHint('Password'),
        TestAccounts.newPassword,
      );
      await tester.enterText(
        textFormFieldByHint('Confirm password'),
        TestAccounts.newPassword,
      );
      await tester.pump();

      await tapAndSettle(tester, actionButton('Create account'));

      expect(
        find.text('This email is already registered, login instead'),
        findsOneWidget,
      );
      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets(
      'logs in with a seeded mock account and rejects bad credentials',
      (tester) async {
        await launchApp(tester);
        await tapAndSettle(tester, outlinedActionButton('Log in'));

        await enterLoginCredentials(
          tester,
          email: TestAccounts.existingEmail,
          password: 'wrongpassword',
        );
        await tapAndSettle(tester, actionButton('Log in'));

        expect(find.text('Invalid email or password'), findsOneWidget);
        expect(find.text('Welcome back'), findsOneWidget);

        await enterLoginCredentials(
          tester,
          email: TestAccounts.existingEmail,
          password: TestAccounts.existingPassword,
        );
        await tapAndSettle(tester, actionButton('Log in'));

        await pumpUntilVisible(tester, find.text('Home'));
        expect(find.text('Library'), findsOneWidget);
      },
    );

    testWidgets('shows an error for an unknown forgot-password email', (
      tester,
    ) async {
      await launchApp(tester);
      await tapAndSettle(tester, outlinedActionButton('Log in'));
      await tapAndSettle(tester, textButton('Forgot password?'));

      await pumpUntilVisible(tester, find.text('Reset your password'));
      await tester.enterText(
        textFormFieldByHint('Email address'),
        TestAccounts.missingEmail,
      );
      await tester.pump();
      await tapAndSettle(tester, actionButton('Send reset link'));

      expect(find.text('No account found with this email'), findsOneWidget);
      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);
    });

    testWidgets('returns to login for a valid forgot-password email', (
      tester,
    ) async {
      await launchApp(tester);
      await tapAndSettle(tester, outlinedActionButton('Log in'));
      await tapAndSettle(tester, textButton('Forgot password?'));

      await pumpUntilVisible(tester, find.text('Reset your password'));
      await tester.enterText(
        textFormFieldByHint('Email address'),
        TestAccounts.existingEmail,
      );
      await tester.pump();
      await tester.tap(actionButton('Send reset link'));
      await tester.pump();

      await pumpUntilVisible(tester, find.text('Welcome back'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(textButton('Forgot password?'), findsOneWidget);
    });

    testWidgets(
      'supports retrying forgot password from invalid to valid email',
      (tester) async {
        await launchApp(tester);
        await tapAndSettle(tester, outlinedActionButton('Log in'));
        await tapAndSettle(tester, textButton('Forgot password?'));

        await pumpUntilVisible(tester, find.text('Reset your password'));
        await tester.enterText(
          textFormFieldByHint('Email address'),
          TestAccounts.missingEmail,
        );
        await tester.pump();
        await tapAndSettle(tester, actionButton('Send reset link'));

        expect(find.text('No account found with this email'), findsOneWidget);
        expect(find.text('Reset your password'), findsOneWidget);

        await tester.tap(textFormFieldByHint('Email address'));
        await tester.pumpAndSettle();
        await tester.enterText(
          textFormFieldByHint('Email address'),
          TestAccounts.existingEmail,
        );
        await tester.pumpAndSettle();
        await tester.tap(actionButton('Send reset link'));
        await tester.pump();

        await pumpUntilVisible(tester, find.text('Welcome back'));
        await tester.pumpAndSettle();
        expect(find.text('Welcome back'), findsOneWidget);
        expect(textButton('Forgot password?'), findsOneWidget);
      },
    );
  });
}
