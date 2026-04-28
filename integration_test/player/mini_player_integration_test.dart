import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/mock_data/mock_tracks.dart';

import '../helpers/app_test_helpers.dart';

/// Player integration: Home -> tap a track tile -> MiniPlayer surfaces ->
/// play/pause toggle -> title in MiniPlayer matches the tile.
///
/// Backed by MockTracks; no audio asset playback is awaited (just_audio is
/// allowed to fire-and-forget on test devices).
void main() {
  ensureBinding();

  group('mini player integration', () {
    testWidgets('tapping a Home track tile populates and toggles the MiniPlayer',
        (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      // The first liked track is rendered as a grid tile keyed by its id.
      final firstTrack = MockTracks.likedTracks.first;
      final tileFinder = byKey('home.trackTile.${firstTrack.id}');
      expect(tileFinder, findsOneWidget);

      // Tap the tile to start playback.
      await tester.tap(tileFinder);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(byKey('miniPlayer.root'), findsOneWidget);

      // The MiniPlayer title should match the tapped tile's title.
      final titleWidget = tester.widget<Text>(byKey('miniPlayer.title'));
      expect(titleWidget.data, firstTrack.title);

      // The play/pause control should toggle without throwing. We pump
      // briefly between taps to let just_audio swallow its async load.
      await tester.tap(byKey('miniPlayer.playPause'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(byKey('miniPlayer.playPause'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(byKey('miniPlayer.root'), findsOneWidget);
    });

    testWidgets("Today's Pick play button surfaces hot track in MiniPlayer",
        (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      final hot = MockTracks.hotTrack;
      final pickButton = byKey('home.todayPick.0');
      expect(pickButton, findsOneWidget);

      await tester.tap(pickButton);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(byKey('miniPlayer.root'), findsOneWidget);
      final titleWidget = tester.widget<Text>(byKey('miniPlayer.title'));
      expect(titleWidget.data, hot.title);
    });
  });
}
