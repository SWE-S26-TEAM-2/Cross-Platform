import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// STABILITY TESTS
/// 
/// Coverage: STB-100 through STB-105, STB-108
/// These tests verify app stability under repeated user actions.
/// Focus: memory leaks, state corruption, UI freezes, crash prevention.

void main() {
  ensureBinding();

  group('stability', () {
    testWidgets('STB-100: tab navigation survives 10 complete cycles', (
      tester,
    ) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      final tabs = ['Feed', 'Search', 'Library', 'Upgrade', 'Home'];

      for (var cycle = 0; cycle < 10; cycle++) {
        for (final tab in tabs) {
          await openBottomTab(tester, tab);
        }
      }

      // App should be responsive and on Home
      expect(find.text('Home'), findsWidgets);
      expect(find.text("TODAY'S PICK"), findsOneWidget);
    });

    testWidgets('STB-101: repeated failed logins remain stable', (
      tester,
    ) async {
      await launchApp(tester);
      await tapAndSettle(tester, outlinedActionButton('Log in'));

      for (var i = 0; i < 10; i++) {
        await tester.enterText(
          textFormFieldByHint('Email address'),
          TestAccounts.existingEmail,
        );
        await tester.enterText(
          textFormFieldByHint('Password'),
          'wrongpassword',
        );
        await tester.pump();
        await tapAndSettle(tester, actionButton('Log in'));

        expect(find.text('Invalid email or password'), findsOneWidget);
      }

      // Form should still be usable
      expect(textFormFieldByHint('Email address'), findsOneWidget);
      expect(actionButton('Log in'), findsOneWidget);
    });

    testWidgets('STB-102: repeated search queries remain stable', (
      tester,
    ) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');
      final queries = ['luther', 'plan', 'beat', 'a', 'xyz', 'the'];

      for (var cycle = 0; cycle < 10; cycle++) {
        for (final query in queries) {
          await tester.enterText(searchField, query);
          await tester.pumpAndSettle();
        }
        // Clear between cycles
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
      }

      // Search should still work
      await tester.enterText(searchField, 'luther');
      await tester.pumpAndSettle();
      expect(find.text('luther'), findsWidgets);
    });

    testWidgets('STB-103: auth screen back/forward navigation stays stable', (
      tester,
    ) async {
      await launchApp(tester);

      for (var cycle = 0; cycle < 10; cycle++) {
        // To signup and back
        await tapAndSettle(tester, actionButton('Create an account'));
        await pumpUntilVisible(tester, find.text('Create your account'));
        await tester.pageBack();
        await tester.pumpAndSettle();

        // To login and back
        await tapAndSettle(tester, outlinedActionButton('Log in'));
        await pumpUntilVisible(tester, find.text('Welcome back'));
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // Should be back at welcome with no stack issues
      expect(actionButton('Create an account'), findsOneWidget);
      expect(outlinedActionButton('Log in'), findsOneWidget);
    });

    testWidgets('STB-104: forgot password retry flow remains stable', (
      tester,
    ) async {
      await launchApp(tester);
      await tapAndSettle(tester, outlinedActionButton('Log in'));

      for (var i = 0; i < 5; i++) {
        await tapAndSettle(tester, textButton('Forgot password?'));
        await pumpUntilVisible(tester, find.text('Reset your password'));

        await tester.enterText(
          textFormFieldByHint('Email address'),
          TestAccounts.missingEmail,
        );
        await tester.pump();
        await tapAndSettle(tester, actionButton('Send reset link'));

        expect(find.text('No account found with this email'), findsOneWidget);

        // Go back to login
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // Should still be on login screen
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('STB-108: full session flow completes multiple times', (
      tester,
    ) async {
      // Complete user journey: login → visit tabs → search → logout (simulated)
      for (var session = 0; session < 3; session++) {
        await launchApp(tester);
        await loginAsSeededUser(tester);

        // Visit all tabs
        await openBottomTab(tester, 'Feed');
        await openBottomTab(tester, 'Search');

        // Perform a search
        final searchField = textFieldByHint('Search');
        await tester.enterText(searchField, 'luther');
        await tester.pumpAndSettle();

        // Continue navigation
        await openBottomTab(tester, 'Library');
        await openBottomTab(tester, 'Upgrade');
        await openBottomTab(tester, 'Home');

        expect(find.text("TODAY'S PICK"), findsOneWidget);

        // Note: Logout UI not implemented yet
        // When available, add: await logoutUser(tester);
      }
    });

    testWidgets('rapid tab switching does not crash', (tester) async {
      // STB-100 variant: Fast switching without settle
      await launchApp(tester);
      await loginAsSeededUser(tester);

      final tabs = ['Feed', 'Search', 'Library', 'Upgrade', 'Home'];

      // Rapid switches with minimal pump time
      for (var i = 0; i < 20; i++) {
        final tab = tabs[i % tabs.length];
        await tester.tap(find.text(tab));
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Let everything settle
      await tester.pumpAndSettle();

      // App should be responsive
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
