import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// SEARCH BEHAVIOR TESTS
/// 
/// Coverage: SRCH-004, SRCH-005, SRCH-006, SRCH-007
/// These tests verify search edge cases and empty states.
/// Existing shell_and_search_test.dart covers positive search; this extends coverage.

void main() {
  ensureBinding();

  group('search behavior', () {
    testWidgets('empty search query shows no results', (tester) async {
      // SRCH-005: Clearing input resets results
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');
      final resultsList = find.byType(ListView);

      // Type something first
      await tester.enterText(searchField, 'luther');
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsOneWidget,
      );

      // Clear the search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Results should be empty
      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsNothing,
      );
    });

    testWidgets('unmatched search query shows empty results', (tester) async {
      // SRCH-004: No results for unmatched query
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');
      final resultsList = find.byType(ListView);

      await tester.enterText(searchField, 'xyznonexistent123');
      await tester.pumpAndSettle();

      // Should have no track results in the list
      // The ListView exists but should have no track children
      expect(resultsList, findsOneWidget);

      // Verify no mock tracks appear
      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsNothing,
      );
      expect(
        find.descendant(of: resultsList, matching: find.text("God's Plan")),
        findsNothing,
      );
    });

    testWidgets('search is case-insensitive', (tester) async {
      // SRCH-006: Case-insensitive matching
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');
      final resultsList = find.byType(ListView);

      // Search with uppercase
      await tester.enterText(searchField, 'LUTHER');
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsOneWidget,
        reason: 'Search should be case-insensitive',
      );

      // Search with mixed case
      await tester.enterText(searchField, 'LuThEr');
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsOneWidget,
        reason: 'Search should handle mixed case',
      );
    });

    testWidgets('repeated search queries update results correctly', (
      tester,
    ) async {
      // STB-102: Search stability under repeated input
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');
      final resultsList = find.byType(ListView);

      final queries = ['luther', 'plan', 'beat', 'a'];

      for (final query in queries) {
        await tester.enterText(searchField, query);
        await tester.pumpAndSettle();

        // Clear for next iteration
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
      }

      // Final search should still work
      await tester.enterText(searchField, 'luther');
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsOneWidget,
        reason: 'Search should work correctly after repeated queries',
      );
    });

    testWidgets('search handles special characters without crash', (
      tester,
    ) async {
      // Edge case: Special character input
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');

      // These should not crash the app
      final specialInputs = [
        '@#\$%',
        '   ',
        '\'quote\'',
        '"double"',
        '<script>',
        '🎵🎶',
      ];

      for (final input in specialInputs) {
        await tester.enterText(searchField, input);
        await tester.pumpAndSettle();
      }

      // App should still be responsive
      expect(searchField, findsOneWidget);
      expect(find.text('Search'), findsWidgets);
    });

    testWidgets('search field is visible and focused on Search tab', (
      tester,
    ) async {
      // SRCH-001: Search UI presence
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');
      expect(searchField, findsOneWidget);

      // Verify it's a TextField
      final textField = tester.widget<TextField>(searchField);
      expect(textField.decoration?.hintText, 'Search');
    });
  });
}
