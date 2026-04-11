import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/screens/library/library_screen.dart';
import 'package:my_project/screens/library/liked_tracks_screen.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/mock_data/mock_tracks.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

/// Wraps a widget in MaterialApp so Flutter can render it in tests
Widget _wrap(Widget child) => MaterialApp(home: child);

/// A fake track used to satisfy MiniPlayer in isolation tests
Track get _fakeTrack => MockTracks.recentlyPlayedTracks.first;

// ── Test doubles ────────────────────────────────────────────────────────────

/// Minimal stand-in for RootScreen that only tests the sub-screen logic.
/// We don't spin up AudioPlayer or just_audio in unit tests.
class _FakeRoot extends StatefulWidget {
  const _FakeRoot();

  @override
  State<_FakeRoot> createState() => _FakeRootState();
}

class _FakeRootState extends State<_FakeRoot> {
  int _selectedIndex = 0;

  // Per-tab sub-screen map (mirrors real root.dart behaviour)
  final Map<int, Widget> _subScreens = {};

  void _pushSubScreen(Widget screen) =>
      setState(() => _subScreens[_selectedIndex] = screen);

  void _popSubScreen() => setState(() => _subScreens.remove(_selectedIndex));

  static const _tabs = [
    Text('HomeTab'),
    Text('FeedTab'),
    Text('SearchTab'),
    // index 3 = Library — built dynamically below
    Text('UpgradeTab'),
  ];

  Widget _body() {
    if (_subScreens.containsKey(_selectedIndex)) {
      return _subScreens[_selectedIndex]!;
    }
    if (_selectedIndex == 3) {
      return LibraryScreen(onNavigate: _pushSubScreen, onBack: _popSubScreen);
    }
    return _tabs[_selectedIndex < 3 ? _selectedIndex : _selectedIndex - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player — always visible
          MiniPlayer(track: _fakeTrack, isPlaying: false, onPlay: () {}),
          // Simplified tab bar with just Home (0) and Library (3)
          Row(
            children: [
              TextButton(
                key: const Key('tab_home'),
                onPressed: () => setState(() => _selectedIndex = 0),
                child: const Text('Home'),
              ),
              TextButton(
                key: const Key('tab_library'),
                onPressed: () => setState(() => _selectedIndex = 3),
                child: const Text('Library'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── Group 1: Navigation ───────────────────────────────────────────────────
  group('Liked Tracks navigation', () {
    testWidgets('tapping Liked Tracks tile shows LikedTracksScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const _FakeRoot()));

      // Switch to Library tab
      await tester.tap(find.byKey(const Key('tab_library')));
      await tester.pumpAndSettle();

      // Tap the Liked Tracks tile
      await tester.tap(find.text('Liked Tracks'));
      await tester.pumpAndSettle();

      // LikedTracksScreen should be visible (it has "Your likes" title)
      expect(find.text('Your likes'), findsOneWidget);

      // LibraryScreen title should no longer be visible
      expect(find.text('Library'), findsNothing);
    });

    testWidgets('back button on LikedTracksScreen returns to LibraryScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const _FakeRoot()));

      // Go to Library → Liked Tracks
      await tester.tap(find.byKey(const Key('tab_library')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Liked Tracks'));
      await tester.pumpAndSettle();

      // Tap the back chevron
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Should be back on LibraryScreen
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Your likes'), findsNothing);
    });

    testWidgets('switching tabs and returning restores LikedTracksScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const _FakeRoot()));

      // Go to Library → Liked Tracks
      await tester.tap(find.byKey(const Key('tab_library')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Liked Tracks'));
      await tester.pumpAndSettle();

      // Switch to Home tab
      await tester.tap(find.byKey(const Key('tab_home')));
      await tester.pumpAndSettle();

      expect(find.text('Your likes'), findsNothing);

      // Switch back to Library tab
      await tester.tap(find.byKey(const Key('tab_library')));
      await tester.pumpAndSettle();

      // LikedTracksScreen should still be showing
      expect(find.text('Your likes'), findsOneWidget);
    });
  });

  // ── Group 2: Mini player persistence ─────────────────────────────────────
  group('Mini player persistence', () {
    testWidgets('MiniPlayer is visible on LibraryScreen', (tester) async {
      await tester.pumpWidget(_wrap(const _FakeRoot()));

      await tester.tap(find.byKey(const Key('tab_library')));
      await tester.pumpAndSettle();

      expect(find.byType(MiniPlayer), findsOneWidget);
    });

    testWidgets('MiniPlayer stays visible after opening LikedTracksScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const _FakeRoot()));

      await tester.tap(find.byKey(const Key('tab_library')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Liked Tracks'));
      await tester.pumpAndSettle();

      // MiniPlayer must still be in the tree
      expect(find.byType(MiniPlayer), findsOneWidget);
    });

    testWidgets('MiniPlayer stays visible after pressing back', (tester) async {
      await tester.pumpWidget(_wrap(const _FakeRoot()));

      await tester.tap(find.byKey(const Key('tab_library')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Liked Tracks'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byType(MiniPlayer), findsOneWidget);
    });
  });

  // ── Group 3: Search filtering ─────────────────────────────────────────────
  group('LikedTracksScreen search', () {
    /// Builds a standalone LikedTracksScreen with a fake onBack
    Widget _likedScreen() => _wrap(LikedTracksScreen(onBack: () {}));

    testWidgets('search bar filters tracks by title', (tester) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      // Get the first track title from mock data
      final firstTitle = MockTracks.recentlyPlayedTracks.first.title;

      // Type the first track's title into the search field
      await tester.enterText(find.byType(TextField), firstTitle);
      await tester.pumpAndSettle();

      // That track should still appear
      expect(find.text(firstTitle), findsWidgets);
    });

    testWidgets('search bar filters tracks by artist', (tester) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      final firstArtist = MockTracks.recentlyPlayedTracks.first.artist;

      await tester.enterText(find.byType(TextField), firstArtist);
      await tester.pumpAndSettle();

      expect(find.text(firstArtist), findsWidgets);
    });

    testWidgets('search with no match shows empty list', (tester) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      // Type something that won't match any track
      await tester.enterText(find.byType(TextField), 'zzzzzz_no_match_zzzzzz');
      await tester.pumpAndSettle();

      // None of the real track titles should be visible
      for (final track in MockTracks.recentlyPlayedTracks) {
        expect(find.text(track.title), findsNothing);
      }
    });

    testWidgets('clearing search restores full list', (tester) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      final firstTitle = MockTracks.recentlyPlayedTracks.first.title;

      // Filter down
      await tester.enterText(find.byType(TextField), 'zzzzzz_no_match_zzzzzz');
      await tester.pumpAndSettle();

      // Clear the search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // First track should be back
      expect(find.text(firstTitle), findsWidgets);
    });
  });

  // ── Group 4: Sort options ─────────────────────────────────────────────────
  group('LikedTracksScreen sort', () {
    Widget _likedScreen() => _wrap(LikedTracksScreen(onBack: () {}));

    Future<void> _openSortSheet(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();
    }

    testWidgets('sort bottom sheet opens when sort icon is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      await _openSortSheet(tester);

      expect(find.text('Sort by'), findsOneWidget);
      expect(find.text('Recently Added'), findsOneWidget);
      expect(find.text('First Added'), findsOneWidget);
      expect(find.text('Track Name'), findsOneWidget);
      expect(find.text('Artist'), findsOneWidget);
    });

    testWidgets('selecting Track Name sorts list alphabetically by title', (
      tester,
    ) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      await _openSortSheet(tester);
      await tester.tap(find.text('Track Name'));
      await tester.pumpAndSettle();

      // Build the expected sorted order
      final sorted = List<Track>.from(MockTracks.recentlyPlayedTracks)
        ..sort((a, b) => a.title.compareTo(b.title));

      // The first title in sorted order should appear before the second
      final firstFinder = find.text(sorted.first.title);
      final secondFinder = find.text(sorted[1].title);

      expect(firstFinder, findsWidgets);
      expect(secondFinder, findsWidgets);

      // Verify vertical position — first item must be above second
      final firstY = tester.getTopLeft(firstFinder.first).dy;
      final secondY = tester.getTopLeft(secondFinder.first).dy;
      expect(firstY, lessThan(secondY));
    });

    testWidgets('selecting Artist sorts list alphabetically by artist', (
      tester,
    ) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      await _openSortSheet(tester);
      await tester.tap(find.text('Artist'));
      await tester.pumpAndSettle();

      final sorted = List<Track>.from(MockTracks.recentlyPlayedTracks)
        ..sort((a, b) => a.artist.compareTo(b.artist));

      final firstFinder = find.text(sorted.first.artist);
      final secondFinder = find.text(sorted[1].artist);

      expect(firstFinder, findsWidgets);
      expect(secondFinder, findsWidgets);

      final firstY = tester.getTopLeft(firstFinder.first).dy;
      final secondY = tester.getTopLeft(secondFinder.first).dy;
      expect(firstY, lessThan(secondY));
    });

    testWidgets('selecting First Added reverses the list', (tester) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      await _openSortSheet(tester);
      await tester.tap(find.text('First Added'));
      await tester.pumpAndSettle();

      final reversed = MockTracks.recentlyPlayedTracks.reversed.toList();

      final firstFinder = find.text(reversed.first.title);
      final lastFinder = find.text(reversed.last.title);

      expect(firstFinder, findsWidgets);
      expect(lastFinder, findsWidgets);

      final firstY = tester.getTopLeft(firstFinder.first).dy;
      final lastY = tester.getTopLeft(lastFinder.first).dy;
      expect(firstY, lessThan(lastY));
    });

    testWidgets('selected sort option shows a checkmark', (tester) async {
      await tester.pumpWidget(_likedScreen());
      await tester.pumpAndSettle();

      await _openSortSheet(tester);

      // Tap Track Name
      await tester.tap(find.text('Track Name'));
      await tester.pumpAndSettle();

      // Re-open the sheet
      await _openSortSheet(tester);

      // Checkmark icon should be visible
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
