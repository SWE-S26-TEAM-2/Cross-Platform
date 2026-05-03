import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/app_test_helpers.dart';

/// Player integration: Home -> tap a track tile -> MiniPlayer surfaces ->
/// play/pause toggle -> title in MiniPlayer matches the tile.
///
/// Uses the integration harness feed from `launchApp`: first "Your likes" tile
/// is keyed `home.trackTile.following-1`. No full audio playback is awaited.
void main() {
  ensureBinding();

  group('mini player integration', () {
    testWidgets('tapping a Home track tile populates and toggles the MiniPlayer',
        (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      // First tile on Home "Your likes" comes from following feed → following-1.
      const expectedTitle = 'luther';
      final tileFinder = byKey('home.trackTile.following-1');
      expect(tileFinder, findsOneWidget);

      // Tap the tile to start playback.
      await tester.tap(tileFinder);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(byKey('miniPlayer.root'), findsOneWidget);

      // The MiniPlayer title should match the tapped tile's title.
      final titleWidget = tester.widget<Text>(byKey('miniPlayer.title'));
      expect(titleWidget.data, expectedTitle);

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

      const expectedTitle = 'luther';
      final pickButton = byKey('home.todayPick.0');
      expect(pickButton, findsOneWidget);

      await tester.tap(pickButton);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(byKey('miniPlayer.root'), findsOneWidget);
      final titleWidget = tester.widget<Text>(byKey('miniPlayer.title'));
      expect(titleWidget.data, expectedTitle);
    });
  });
}
