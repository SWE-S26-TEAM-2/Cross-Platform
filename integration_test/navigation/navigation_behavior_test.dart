import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// NAVIGATION BEHAVIOR TESTS
/// 
/// Coverage: NAV-007, NAV-008, Critical #6-7
/// These tests verify tab navigation behavior and user-specific content.
/// Existing shell_and_search_test.dart remains the smoke baseline.

void main() {
  ensureBinding();

  group('navigation behavior', () {
    testWidgets('user cycles through all tabs multiple times without crash', (
      tester,
    ) async {
      // NAV-007 / STB-100: Tab cycling stability
      await launchApp(tester);
      await loginAsSeededUser(tester);

      final tabs = ['Feed', 'Search', 'Library', 'Upgrade', 'Home'];

      // 5 complete cycles
      for (var cycle = 0; cycle < 5; cycle++) {
        for (final tab in tabs) {
          await openBottomTab(tester, tab);
        }
      }

      // Final state: Home tab active with expected content
      expect(find.text('Home'), findsWidgets);
      expect(find.text("TODAY'S PICK"), findsOneWidget);
    });

    testWidgets('Library screen shows expected sections after login', (
      tester,
    ) async {
      // Critical #7: User-specific content verification
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Library');

      // Library should show user's content sections
      expect(find.text('Library'), findsWidgets);
      expect(find.text('Liked Tracks'), findsOneWidget);
      expect(find.text('Playlists'), findsOneWidget);
      expect(find.text('Albums'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Stations'), findsOneWidget);
      expect(find.text('Your insights'), findsOneWidget);
      expect(find.text('Your uploads'), findsOneWidget);
    });

    testWidgets('Home screen shows personalized sections after login', (
      tester,
    ) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      // Should already be on Home
      expect(find.text("TODAY'S PICK"), findsOneWidget);
      expect(find.text('More of what you like'), findsOneWidget);
      expect(find.text('Mixed for You'), findsOneWidget);
      expect(find.text('Albums for You'), findsOneWidget);
    });

    testWidgets('Feed screen shows Following and Discover sections', (
      tester,
    ) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Feed');

      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('Upgrade screen shows subscription pitch', (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Upgrade');

      expect(
        find.text("What's next in music is first on SoundCloud"),
        findsOneWidget,
      );
    });

    testWidgets('returning to Home from other tabs shows consistent content', (
      tester,
    ) async {
      // NAV-008: State persistence verification
      await launchApp(tester);
      await loginAsSeededUser(tester);

      // Note initial Home content
      expect(find.text("TODAY'S PICK"), findsOneWidget);

      // Visit all other tabs
      await openBottomTab(tester, 'Feed');
      await openBottomTab(tester, 'Search');
      await openBottomTab(tester, 'Library');
      await openBottomTab(tester, 'Upgrade');

      // Return to Home
      await openBottomTab(tester, 'Home');

      // Content should be consistent
      expect(find.text("TODAY'S PICK"), findsOneWidget);
      expect(find.text('More of what you like'), findsOneWidget);
    });
  });
}
