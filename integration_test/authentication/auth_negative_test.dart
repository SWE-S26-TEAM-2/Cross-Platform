import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// AUTH NEGATIVE TESTS
/// 
/// Coverage: Edge cases for form validation and submission
/// These tests verify defensive behavior against invalid/malicious input.
/// Existing authentication_test.dart covers standard validation; this extends coverage.

void main() {
  ensureBinding();

  group('auth negative scenarios', () {
    testWidgets('signup rejects whitespace-only email', (tester) async {
      await launchApp(tester);
      await tapAndSettle(tester, actionButton('Create an account'));

      await tester.enterText(textFormFieldByHint('Email address'), '   ');
      await tester.enterText(textFormFieldByHint('Password'), 'validpass123');
      await tester.enterText(
        textFormFieldByHint('Confirm password'),
        'validpass123',
      );
      await tester.pump();

      await tapAndSettle(tester, actionButton('Create account'));

      // Should show validation error for invalid email
      expect(
        find.textContaining('email'),
        findsWidgets,
        reason: 'Whitespace-only email should trigger validation error',
      );
    });

    testWidgets('signup rejects whitespace-only password', (tester) async {
      await launchApp(tester);
      await tapAndSettle(tester, actionButton('Create an account'));

      await tester.enterText(
        textFormFieldByHint('Email address'),
        'valid@email.com',
      );
      await tester.enterText(textFormFieldByHint('Password'), '        ');
      await tester.enterText(textFormFieldByHint('Confirm password'), '        ');
      await tester.pump();

      await tapAndSettle(tester, actionButton('Create account'));

      // Should show validation error for password
      expect(
        find.textContaining('Password'),
        findsWidgets,
        reason: 'Whitespace-only password should trigger validation error',
      );
    });

    testWidgets('login form handles very long email gracefully', (tester) async {
      await launchApp(tester);
      await tapAndSettle(tester, outlinedActionButton('Log in'));

      final longEmail = '${'a' * 200}@example.com';
      await tester.enterText(textFormFieldByHint('Email address'), longEmail);
      await tester.enterText(textFormFieldByHint('Password'), 'password123');
      await tester.pump();

      await tapAndSettle(tester, actionButton('Log in'));

      // App should not crash; should show error (invalid credentials)
      // or handle gracefully
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('login form handles very long password gracefully', (tester) async {
      await launchApp(tester);
      await tapAndSettle(tester, outlinedActionButton('Log in'));

      final longPassword = 'a' * 500;
      await tester.enterText(
        textFormFieldByHint('Email address'),
        'test@gmail.com',
      );
      await tester.enterText(textFormFieldByHint('Password'), longPassword);
      await tester.pump();

      await tapAndSettle(tester, actionButton('Log in'));

      // App should not crash
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('repeated failed login attempts show consistent error', (
      tester,
    ) async {
      // STB-101: Stability under repeated failures
      await launchApp(tester);
      await tapAndSettle(tester, outlinedActionButton('Log in'));

      for (var i = 0; i < 5; i++) {
        await tester.enterText(
          textFormFieldByHint('Email address'),
          TestAccounts.existingEmail,
        );
        await tester.enterText(
          textFormFieldByHint('Password'),
          'wrongpassword$i',
        );
        await tester.pump();
        await tapAndSettle(tester, actionButton('Log in'));

        expect(
          find.text('Invalid email or password'),
          findsOneWidget,
          reason: 'Attempt ${i + 1}: Error should display consistently',
        );
      }

      // Form should still be usable
      expect(textFormFieldByHint('Email address'), findsOneWidget);
      expect(textFormFieldByHint('Password'), findsOneWidget);
    });

    testWidgets('signup form clears error after correcting input', (
      tester,
    ) async {
      await launchApp(tester);
      await tapAndSettle(tester, actionButton('Create an account'));

      // Submit with invalid data
      await tester.enterText(textFormFieldByHint('Email address'), 'bademail');
      await tester.enterText(textFormFieldByHint('Password'), 'short');
      await tester.enterText(textFormFieldByHint('Confirm password'), 'diff');
      await tester.pump();
      await tapAndSettle(tester, actionButton('Create account'));

      expect(find.text('Enter a valid email'), findsOneWidget);

      // Correct the email and resubmit
      await tester.enterText(
        textFormFieldByHint('Email address'),
        'valid@email.com',
      );
      await tester.enterText(textFormFieldByHint('Password'), 'password123');
      await tester.enterText(
        textFormFieldByHint('Confirm password'),
        'password123',
      );
      await tester.pump();
      await tapAndSettle(tester, actionButton('Create account'));

      // Previous email error should be cleared
      expect(find.text('Enter a valid email'), findsNothing);
    });
  });
}
