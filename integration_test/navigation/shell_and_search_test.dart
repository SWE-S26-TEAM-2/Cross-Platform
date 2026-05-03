import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

void main() {
  ensureBinding();

  group('search and root shell', () {
    testWidgets('opens the available bottom tabs after login', (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Upgrade'), findsOneWidget);

      await openBottomTab(tester, 'Feed');
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);

      await openBottomTab(tester, 'Search');
      expect(textFieldByHint('Search'), findsOneWidget);

      await openBottomTab(tester, 'Library');
      expect(find.text('Liked Tracks'), findsOneWidget);
      expect(find.text('Playlists'), findsOneWidget);

      await openBottomTab(tester, 'Upgrade');
      expect(
        find.text("What's next in music is first on SoundCloud"),
        findsOneWidget,
      );

      await openBottomTab(tester, 'Home');
      expect(find.text("TODAY'S PICK"), findsOneWidget);
    });

    testWidgets('filters local search results for known mock tracks', (
      tester,
    ) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Search');

      final searchField = textFieldByHint('Search');
      final resultsList = find.byType(ListView);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'luther');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(resultsList, findsOneWidget);

      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: resultsList,
          matching: find.text('Kendrick Lamar ft. SZA'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: resultsList, matching: find.text("God's Plan")),
        findsNothing,
      );

      await tester.enterText(searchField, 'plan');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: resultsList, matching: find.text("God's Plan")),
        findsOneWidget,
      );
      expect(
        find.descendant(of: resultsList, matching: find.text('Drake')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: resultsList, matching: find.text('luther')),
        findsNothing,
      );
    });
  });
}
