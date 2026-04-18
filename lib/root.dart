import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/providers/track_provider.dart';
import 'package:my_project/providers/auth_providers.dart';
import 'package:my_project/screens/feed/feed_screen.dart';
import 'package:my_project/screens/search/search_screen.dart';
import 'package:my_project/screens/upgrade/upgrade_screen.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/navigation/bottom_nav_bar.dart';
import 'package:my_project/screens/home/home_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_project/screens/library/library_screen.dart';
import 'package:path_provider/path_provider.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _selectedIndex = 0;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _hasLoaded = false;
  bool _isLoadingStream = false;
  Track _currentTrack = MockTracks.hotTrack;

  // Sub-screens
  final Map<int, Widget> _subScreens = {};

  void _pushSubScreen(Widget screen) {
    setState(() => _subScreens[_selectedIndex] = screen);
  }

  void _popSubScreen() {
    setState(() => _subScreens.remove(_selectedIndex));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _handlePlay(Track track) async {
    print('=== HANDLE PLAY CALLED ===');
    print('Track: ${track.title}');

    // ── Pause if same track is already playing ──────────────────────────────
    if (_currentTrack.id == track.id && _isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      print('=== PLAYER PAUSED ===');
      return;
    }

    // ── Load new track ───────────────────────────────────────────────────────
    if (_currentTrack.id != track.id || !_hasLoaded) {
      // Mock track — use local asset directly
      if (track.fileUrl.startsWith('assets/')) {
        print('=== LOADING LOCAL ASSET ===');
        setState(() => _isLoadingStream = true);
        await _player.setAsset(track.fileUrl);
        setState(() {
          _isLoadingStream = false;
          _hasLoaded = true;
          _currentTrack = track;
        });
      }
      // Real API track — fetch playback info then download audio with auth token
      else {
        print('=== FETCHING PLAYBACK INFO ===');
        setState(() => _isLoadingStream = true);
        try {
          // Step 1 — get playback info (stream_url + waveform + duration)
          final playback = await ref.read(
            trackPlaybackProvider(track.id).future,
          );
          print('=== STREAM URL: ${playback.fullStreamUrl} ===');

          // Step 2 — download audio to temp file using Dio with auth header
          // TODO: remove this block and replace with direct streaming
          // once GET /tracks/{id}/audio endpoint is fixed on the backend
          final token = ref.read(authProvider).tokens?.accessToken ?? '';
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/${track.id}.mp3');

          if (!await tempFile.exists()) {
            print('=== DOWNLOADING TO TEMP FILE ===');
            await Dio().download(
              playback.fullStreamUrl,
              tempFile.path,
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
            print('=== DOWNLOAD COMPLETE ===');
          } else {
            print('=== USING CACHED TEMP FILE ===');
          }

          // Step 3 — play from temp file
          await _player.setFilePath(tempFile.path);

          setState(() {
            _isLoadingStream = false;
            _hasLoaded = true;
            _currentTrack = track;
          });
        } catch (e) {
          print('=== PLAYBACK FETCH FAILED: $e ===');
          print('=== TRACK ID: ${track.id} ===');
          setState(() => _isLoadingStream = false);
          return;
        }
      }
    }

    // ── Play ─────────────────────────────────────────────────────────────────
    _player.play();
    setState(() => _isPlaying = true);
    print('=== PLAYER PLAYING ===');
  }

  List<Widget> _buildScreens() => [
    HomeScreen(onTrackTap: _handlePlay),
    const FeedScreen(),
    SearchScreen(),
    LibraryScreen(onNavigate: _pushSubScreen, onBack: _popSubScreen),
    const UpgradeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _subScreens[_selectedIndex] ?? _buildScreens()[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            track: _currentTrack,
            isPlaying: _isPlaying,
            isLoading: _isLoadingStream,
            onPlay: () => _handlePlay(_currentTrack),
          ),
          BottomNavBar(
            onTabSelected: (index) => setState(() {
              _selectedIndex = index;
            }),
          ),
        ],
      ),
    );
  }
}
