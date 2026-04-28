import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/models/track.dart';

/// MINI PLAYER WIDGET TESTS
///
/// Coverage: WGT-007 (MiniPlayer widget renders when track is active)
/// Verifies that the mini player displays track information correctly
/// and responds to user interaction.
///
/// The MiniPlayer is always visible after login at the bottom of the screen.

void main() {
  // Test fixture: mock track
  const testTrack = Track(
    id: 'test-1',
    title: 'Test Track Title',
    artist: 'Test Artist Name',
    artworkUrl: 'https://example.com/artwork.png',
    likeCount: 1000,
    duration: 180,
    audioPath: 'assets/audio/test.mp3',
  );

  group('MiniPlayer widget', () {
    testWidgets('renders track title and artist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: false,
              onPlay: () {},
            ),
          ),
        ),
      );

      // Verify track information is displayed
      expect(find.text('Test Track Title'), findsOneWidget);
      expect(find.text('Test Artist Name'), findsOneWidget);
    });

    testWidgets('shows play icon when not playing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: false,
              onPlay: () {},
            ),
          ),
        ),
      );

      // Verify play icon is shown
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
    });

    testWidgets('shows pause icon when playing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: true,
              onPlay: () {},
            ),
          ),
        ),
      );

      // Verify pause icon is shown
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('tapping play button triggers onPlay callback', (
      tester,
    ) async {
      var callbackFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: false,
              onPlay: () {
                callbackFired = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the play button
      final playButton = find.byIcon(Icons.play_arrow_rounded);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify callback was triggered
      expect(callbackFired, isTrue);
    });

    testWidgets('tapping pause button triggers onPlay callback', (
      tester,
    ) async {
      var callbackFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: true,
              onPlay: () {
                callbackFired = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the pause button
      final pauseButton = find.byIcon(Icons.pause_rounded);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      // Verify callback was triggered
      expect(callbackFired, isTrue);
    });

    testWidgets('displays additional controls (cast and favorite)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: false,
              onPlay: () {},
            ),
          ),
        ),
      );

      // Verify additional control icons are present
      expect(find.byIcon(Icons.phone_android), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('updates UI when isPlaying state changes', (tester) async {
      // Start with not playing
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: false,
              onPlay: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Rebuild with playing state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: testTrack,
              isPlaying: true,
              onPlay: () {},
            ),
          ),
        ),
      );

      // Icon should update
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('updates track info when track prop changes', (tester) async {
      const firstTrack = Track(
        id: 'track-1',
        title: 'First Track',
        artist: 'First Artist',
        artworkUrl: '',
        likeCount: 0,
        duration: 100,
        audioPath: '',
      );

      const secondTrack = Track(
        id: 'track-2',
        title: 'Second Track',
        artist: 'Second Artist',
        artworkUrl: '',
        likeCount: 0,
        duration: 100,
        audioPath: '',
      );

      // Render with first track
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: firstTrack,
              isPlaying: false,
              onPlay: () {},
            ),
          ),
        ),
      );

      expect(find.text('First Track'), findsOneWidget);
      expect(find.text('First Artist'), findsOneWidget);

      // Rebuild with second track
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPlayer(
              track: secondTrack,
              isPlaying: false,
              onPlay: () {},
            ),
          ),
        ),
      );

      // Track info should update
      expect(find.text('Second Track'), findsOneWidget);
      expect(find.text('Second Artist'), findsOneWidget);
      expect(find.text('First Track'), findsNothing);
    });
  });
}
