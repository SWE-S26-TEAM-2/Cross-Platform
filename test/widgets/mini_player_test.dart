import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/models/track.dart';

/// MINI PLAYER WIDGET TESTS
///
/// Coverage: WGT-007 (MiniPlayer widget renders when track is active)
/// Updated post-merge: Track model changed from flat artist String to
/// TrackArtist object; MiniPlayer requires onOpenFullPlayer callback.

Track _makeTrack({
  String trackId = 'test-1',
  String title = 'Test Track Title',
  String artistDisplayName = 'Test Artist Name',
}) {
  return Track(
    trackId: trackId,
    title: title,
    streamUrl: 'https://example.com/audio.mp3',
    artist: TrackArtist(
      userId: 'u1',
      username: 'testuser',
      displayName: artistDisplayName,
      followerCount: 0,
    ),
    visibility: 'public',
    processingStatus: 'ready',
    playCount: 0,
  );
}

void main() {
  final testTrack = _makeTrack();

  Widget _wrap(MiniPlayer player) =>
      MaterialApp(home: Scaffold(body: player));

  group('MiniPlayer widget', () {
    testWidgets('renders track title and artist', (tester) async {
      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: false,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.text('Test Track Title'), findsOneWidget);
      expect(find.text('Test Artist Name'), findsOneWidget);
    });

    testWidgets('shows play icon when not playing', (tester) async {
      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: false,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
    });

    testWidgets('shows pause icon when playing', (tester) async {
      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: true,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('tapping play button triggers onPlay callback', (tester) async {
      var callbackFired = false;

      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: false,
        onPlay: () { callbackFired = true; },
        onOpenFullPlayer: () {},
      )));

      await tester.tap(find.byKey(const Key('miniPlayer.playPause')));
      await tester.pumpAndSettle();

      expect(callbackFired, isTrue);
    });

    testWidgets('tapping pause button triggers onPlay callback', (tester) async {
      var callbackFired = false;

      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: true,
        onPlay: () { callbackFired = true; },
        onOpenFullPlayer: () {},
      )));

      await tester.tap(find.byKey(const Key('miniPlayer.playPause')));
      await tester.pumpAndSettle();

      expect(callbackFired, isTrue);
    });

    testWidgets('displays additional controls (cast and favorite)', (tester) async {
      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: false,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.byIcon(Icons.phone_android), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('updates UI when isPlaying state changes', (tester) async {
      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: false,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: true,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('updates track info when track prop changes', (tester) async {
      final firstTrack = _makeTrack(trackId: 'track-1', title: 'First Track', artistDisplayName: 'First Artist');
      final secondTrack = _makeTrack(trackId: 'track-2', title: 'Second Track', artistDisplayName: 'Second Artist');

      await tester.pumpWidget(_wrap(MiniPlayer(
        track: firstTrack,
        isPlaying: false,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.text('First Track'), findsOneWidget);
      expect(find.text('First Artist'), findsOneWidget);

      await tester.pumpWidget(_wrap(MiniPlayer(
        track: secondTrack,
        isPlaying: false,
        onPlay: () {},
        onOpenFullPlayer: () {},
      )));

      expect(find.text('Second Track'), findsOneWidget);
      expect(find.text('Second Artist'), findsOneWidget);
      expect(find.text('First Track'), findsNothing);
    });

    testWidgets('tapping player body triggers onOpenFullPlayer', (tester) async {
      var opened = false;

      await tester.pumpWidget(_wrap(MiniPlayer(
        track: testTrack,
        isPlaying: false,
        onPlay: () {},
        onOpenFullPlayer: () { opened = true; },
      )));

      await tester.tap(find.byKey(const Key('miniPlayer.title')));
      await tester.pumpAndSettle();

      expect(opened, isTrue);
    });
  });
}
