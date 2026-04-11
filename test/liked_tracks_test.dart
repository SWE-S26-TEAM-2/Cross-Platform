import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/screens/library/library_screen.dart';
import 'package:my_project/screens/library/liked_tracks_screen.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/mock_data/mock_tracks.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

Widget wrap(Widget child) => MaterialApp(home: child);

Track get fakeTrack => MockTracks.recentlyPlayedTracks.first;

/// Scoped AppBar title finder (avoids matching tab labels)
Finder appBarTitle(String text) => find.descendant(
      of: find.byType(AppBar),
      matching: find.text(text),
    );

Future<void> goToLibrary(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('tab_library')));
  await tester.pumpAndSettle();
}

Future<void> openLikedTracks(WidgetTester tester) async {
  await tester.tap(find.text('Liked Tracks'));
  await tester.pumpAndSettle();
}

// ── Fake Root ───────────────────────────────────────────────────────────────

class FakeRoot extends StatefulWidget {
  const FakeRoot();

  @override
  State<FakeRoot> createState() => _FakeRootState();
}

class _FakeRootState extends State<FakeRoot> {
  int selectedIndex = 0;
  final Map<int, Widget> subScreens = {};

  void push(Widget screen) =>
      setState(() => subScreens[selectedIndex] = screen);

  void pop() => setState(() => subScreens.remove(selectedIndex));

  Widget body() {
    if (subScreens.containsKey(selectedIndex)) {
      return subScreens[selectedIndex]!;
    }
    if (selectedIndex == 3) {
      return LibraryScreen(onNavigate: push, onBack: pop);
    }
    return const Text('HomeTab');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(track: fakeTrack, isPlaying: false, onPlay: () {}),
          Row(
            children: [
              TextButton(
                key: const Key('tab_home'),
                onPressed: () => setState(() => selectedIndex = 0),
                child: const Text('Home'),
              ),
              TextButton(
                key: const Key('tab_library'),
                onPressed: () => setState(() => selectedIndex = 3),
                child: const Text('Library'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('Navigation', () {
    testWidgets('opens LikedTracksScreen from Library', (tester) async {
      await tester.pumpWidget(wrap(const FakeRoot()));

      await goToLibrary(tester);
      await openLikedTracks(tester);

      expect(find.text('Your likes'), findsOneWidget);
      expect(appBarTitle('Library'), findsNothing);
    });

    testWidgets('back returns to LibraryScreen', (tester) async {
      await tester.pumpWidget(wrap(const FakeRoot()));

      await goToLibrary(tester);
      await openLikedTracks(tester);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(appBarTitle('Library'), findsOneWidget);
      expect(find.text('Your likes'), findsNothing);
    });

    testWidgets('state persists when switching tabs', (tester) async {
      await tester.pumpWidget(wrap(const FakeRoot()));

      await goToLibrary(tester);
      await openLikedTracks(tester);

      await tester.tap(find.byKey(const Key('tab_home')));
      await tester.pumpAndSettle();

      expect(find.text('Your likes'), findsNothing);

      await goToLibrary(tester);

      expect(find.text('Your likes'), findsOneWidget);
    });
  });

  group('MiniPlayer', () {
    testWidgets('visible on LibraryScreen', (tester) async {
      await tester.pumpWidget(wrap(const FakeRoot()));

      await goToLibrary(tester);

      expect(find.byType(MiniPlayer), findsOneWidget);
    });

    testWidgets('persists across navigation', (tester) async {
      await tester.pumpWidget(wrap(const FakeRoot()));

      await goToLibrary(tester);
      await openLikedTracks(tester);

      expect(find.byType(MiniPlayer), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byType(MiniPlayer), findsOneWidget);
    });
  });

  group('Search', () {
    Widget screen() => wrap(LikedTracksScreen(onBack: () {}));

    testWidgets('filters by title', (tester) async {
      await tester.pumpWidget(screen());

      final title = MockTracks.recentlyPlayedTracks.first.title;

      await tester.enterText(find.byType(TextField), title);
      await tester.pumpAndSettle();

      expect(find.text(title), findsWidgets);
    });

    testWidgets('filters by artist', (tester) async {
      await tester.pumpWidget(screen());

      final artist = MockTracks.recentlyPlayedTracks.first.artist;

      await tester.enterText(find.byType(TextField), artist);
      await tester.pumpAndSettle();

      expect(find.text(artist), findsWidgets);
    });

    testWidgets('no results case', (tester) async {
      await tester.pumpWidget(screen());

      await tester.enterText(find.byType(TextField), 'no_match_xyz');
      await tester.pumpAndSettle();

      for (final t in MockTracks.recentlyPlayedTracks) {
        expect(find.text(t.title), findsNothing);
      }
    });

    testWidgets('clearing restores list', (tester) async {
      await tester.pumpWidget(screen());

      final title = MockTracks.recentlyPlayedTracks.first.title;

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text(title), findsWidgets);
    });
  });

  group('Sorting', () {
    Widget screen() => wrap(LikedTracksScreen(onBack: () {}));

    Future<void> openSort(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();
    }

    testWidgets('opens sort sheet', (tester) async {
      await tester.pumpWidget(screen());

      await openSort(tester);

      expect(find.text('Sort by'), findsOneWidget);
    });

    testWidgets('sort by track name', (tester) async {
      await tester.pumpWidget(screen());

      await openSort(tester);
      await tester.tap(find.text('Track Name'));
      await tester.pumpAndSettle();

      final sorted = [...MockTracks.recentlyPlayedTracks]
        ..sort((a, b) => a.title.compareTo(b.title));

      final firstY =
          tester.getTopLeft(find.text(sorted[0].title).first).dy;
      final secondY =
          tester.getTopLeft(find.text(sorted[1].title).first).dy;

      expect(firstY, lessThan(secondY));
    });

    testWidgets('sort by artist', (tester) async {
      await tester.pumpWidget(screen());

      await openSort(tester);
      await tester.tap(find.text('Artist'));
      await tester.pumpAndSettle();

      final sorted = [...MockTracks.recentlyPlayedTracks]
        ..sort((a, b) => a.artist.compareTo(b.artist));

      final firstY =
          tester.getTopLeft(find.text(sorted[0].artist).first).dy;
      final secondY =
          tester.getTopLeft(find.text(sorted[1].artist).first).dy;

      expect(firstY, lessThan(secondY));
    });

    testWidgets('checkmark appears on selected sort', (tester) async {
      await tester.pumpWidget(screen());

      await openSort(tester);
      await tester.tap(find.text('Track Name'));
      await tester.pumpAndSettle();

      await openSort(tester);

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}