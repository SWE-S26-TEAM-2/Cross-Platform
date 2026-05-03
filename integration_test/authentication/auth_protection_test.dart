import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// AUTH PROTECTION TESTS
///
/// Coverage: AUTH-010, AUTH-011, NAV-016, Critical #7
/// These tests verify protected-screen behavior for unauthenticated users.
///
/// Key behaviors verified:
/// - App starts on WelcomeScreen (not logged-in shell)
/// - Post-login content is only accessible after authentication
/// - Login successfully transitions user to protected shell
///
/// NOTE: The app does not implement a navigation guard for /root.
/// These tests verify the intended auth flow, not route blocking.

void main() {
  ensureBinding();

  group('auth protection - pre-login state', () {
    testWidgets('app launches on WelcomeScreen, not logged-in shell', (
      tester,
    ) async {
      // AUTH-011: Unauthenticated user starts on public entry point
      await launchApp(tester);

      // WelcomeScreen content should be visible
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      // Logged-in shell content should NOT be visible
      expect(find.text('Home'), findsNothing);
      expect(find.text('Feed'), findsNothing);
      expect(find.text('Library'), findsNothing);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Upgrade'), findsNothing);
    });

    testWidgets('WelcomeScreen shows public content, not user-specific data', (
      tester,
    ) async {
      await launchApp(tester);

      // Public branding content
      expect(welcomeTaglineFinder(), findsOneWidget);

      // User-specific content should NOT be visible
      expect(find.text("TODAY'S PICK"), findsNothing);
      expect(find.text('Liked Tracks'), findsNothing);
      expect(find.text('Following'), findsNothing);
      expect(find.text('Playlists'), findsNothing);
    });

    testWidgets('only auth entry points available from WelcomeScreen', (
      tester,
    ) async {
      // NAV-016: Header controls hidden when unauthenticated
      await launchApp(tester);

      // Auth entry points exist
      expect(outlinedActionButton('Log in'), findsOneWidget);
      expect(actionButton('Create an account'), findsOneWidget);

      // No bottom navigation tabs (those are in RootScreen)
      expect(find.text('Home'), findsNothing);
      expect(find.text('Feed'), findsNothing);
      expect(find.text('Library'), findsNothing);
    });
  });

  group('auth protection - login grants access', () {
    testWidgets(
      'login transitions user from WelcomeScreen to protected shell',
      (tester) async {
        // AUTH-010: Authenticated user redirected to /discover equivalent
        await launchApp(tester);

        // Confirm starting on WelcomeScreen
        expect(find.text('Create an account'), findsOneWidget);
        expect(find.text('Home'), findsNothing);

        // Perform login
        await loginAsSeededUser(tester);

        // Now on protected shell with bottom tabs
        expect(find.text('Home'), findsWidgets);
        expect(find.text('Feed'), findsWidgets);
        expect(find.text('Library'), findsWidgets);
        expect(find.text('Search'), findsWidgets);
        expect(find.text('Upgrade'), findsWidgets);

        // WelcomeScreen content gone
        expect(find.text('Create an account'), findsNothing);
        expect(welcomeTaglineFinder(), findsNothing);
      },
    );

    testWidgets('protected tabs show user-specific content after login', (
      tester,
    ) async {
      // Critical #7: Protected content becomes available
      await launchApp(tester);
      await loginAsSeededUser(tester);

      // Home shows personalized content
      expect(find.text("TODAY'S PICK"), findsOneWidget);

      // Library shows user-specific sections
      await openBottomTab(tester, 'Library');
      expect(find.text('Liked Tracks'), findsOneWidget);
      expect(find.text('Playlists'), findsOneWidget);
      expect(find.text('Your uploads'), findsOneWidget);
    });

    testWidgets('Feed tab shows Following section only after login', (
      tester,
    ) async {
      await launchApp(tester);

      // Before login: no Following section
      expect(find.text('Following'), findsNothing);

      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Feed');

      // After login: Following section visible
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
    });
  });

  group('auth protection - login flow integrity', () {
    testWidgets('invalid credentials do not grant shell access', (
      tester,
    ) async {
      await launchApp(tester);

      // Navigate to login
      await tapAndSettle(tester, outlinedActionButton('Log in'));

      // Enter invalid credentials
      await enterLoginCredentials(
        tester,
        email: TestAccounts.missingEmail,
        password: 'wrongpassword',
      );
      await tapAndSettle(tester, actionButton('Log in'));

      // Should remain on login screen with error
      expect(find.text('Log in'), findsWidgets);
      expect(find.text('Invalid email or password'), findsOneWidget);

      // Shell content still not accessible
      expect(find.text('Home'), findsNothing);
      expect(find.text("TODAY'S PICK"), findsNothing);
    });

    testWidgets('partial signup does not grant shell access', (tester) async {
      await launchApp(tester);

      // Navigate to signup
      await tapAndSettle(tester, actionButton('Create an account'));

      // Enter only email, no password
      await tester.enterText(
        textFormFieldByHint('Email address'),
        'partial@example.com',
      );
      await tester.pump();

      // Shell content not accessible
      expect(find.text('Home'), findsNothing);
      expect(find.text('Library'), findsNothing);
      expect(find.text("TODAY'S PICK"), findsNothing);
    });

    testWidgets('back from login returns to WelcomeScreen, not shell', (
      tester,
    ) async {
      await launchApp(tester);

      // Navigate to login
      await tapAndSettle(tester, outlinedActionButton('Log in'));
      expect(find.text('Email address'), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back on WelcomeScreen
      expect(find.text('Create an account'), findsOneWidget);
      expect(welcomeTaglineFinder(), findsOneWidget);

      // Not on shell
      expect(find.text('Home'), findsNothing);
    });
  });

  group('auth protection - signup flow', () {
    testWidgets('completed signup leads to login, then shell access', (
      tester,
    ) async {
      await launchApp(tester);

      // Navigate to signup
      await tapAndSettle(tester, actionButton('Create an account'));

      // Complete signup form
      await tester.enterText(textFormFieldByHint('Username'), 'New Listener');
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

      // Current flow requires email verification before returning to login.
      await pumpUntilVisible(tester, find.text('Verify your email'));
      await tapAndSettle(tester, textButton('Back to login'));
      await pumpUntilVisible(tester, find.text('Email address'));

      // Still not on shell yet (need to complete login)
      expect(find.text("TODAY'S PICK"), findsNothing);

      // Now login with new credentials
      await enterLoginCredentials(
        tester,
        email: TestAccounts.newEmail,
        password: TestAccounts.newPassword,
      );
      await tapAndSettle(tester, actionButton('Log in'));
      await pumpUntilVisible(tester, find.text('Home'));

      // Now on protected shell
      expect(find.text('Home'), findsWidgets);
      expect(find.text("TODAY'S PICK"), findsOneWidget);
    });
  });
}
