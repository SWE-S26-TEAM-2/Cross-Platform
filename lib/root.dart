import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/navigation/bottom_nav_bar.dart';
import 'package:my_project/screens/feed/feed_screen.dart';
import 'package:my_project/screens/home/home_screen.dart';
import 'package:my_project/screens/library/library_screen.dart';
import 'package:my_project/screens/search/search_screen.dart';
import 'package:my_project/screens/upgrade/upgrade_screen.dart';
import 'package:my_project/widgets/full_player.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/screens/auth/welcome_screen.dart';
import 'package:my_project/providers/auth_providers.dart';
import './providers/track_provider.dart';
import './providers/library_providers.dart';

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

  Track _currentTrack = MockTracks.hotTrack;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  final Map<int, Widget> _subScreens = {};

  bool _bootstrapped = false;

  void _pushSubScreen(Widget screen) {
    setState(() => _subScreens[_selectedIndex] = screen);
  }

  void _popSubScreen() {
    setState(() => _subScreens.remove(_selectedIndex));
  }

  @override
  void initState() {
    super.initState();
    _listenToPlayer();
  }

  void _listenToPlayer() {
    _positionSub = _player.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _currentPosition = position);
    });

    _durationSub = _player.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() {
        _totalDuration =
            duration ?? Duration(seconds: _currentTrack.durationSeconds ?? 0);
      });
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _handlePlay(Track track) async {
    try {
      final streamData = await ref
          .read(tracksServiceProvider)
          .getTrackStream(trackId: track.trackId);

      final rawUrl = streamData['stream_url'];

      if (rawUrl == null || rawUrl.toString().isEmpty) {
        debugPrint('Invalid stream URL');
        return;
      }

      final url = rawUrl.toString().startsWith('http')
          ? rawUrl.toString()
          : 'https://streamline-swp.duckdns.org$rawUrl';

      if (_currentTrack.trackId == track.trackId && _isPlaying) {
        await _player.pause();
        return;
      }

      if (_currentTrack.trackId != track.trackId || !_hasLoaded) {
        setState(() {
          _hasLoaded = true;
          _currentTrack = track;
          _currentPosition = Duration.zero;
          _totalDuration = Duration(seconds: track.durationSeconds ?? 0);
        });

        try {
          await _player.setUrl(url);
        } catch (e) {
          debugPrint('just_audio load error: $e');
          return;
        }
      }

      await _player.play();

      // Notify the backend a play has started so history/recently-played update.
      ref
          .read(tracksServiceProvider)
          .recordPlay(trackId: track.trackId)
          .then((_) {
            ref.invalidate(recentlyPlayedProvider);
            ref.invalidate(listeningHistoryProvider);
          })
          .catchError((_) {});
    } catch (e, stack) {
      debugPrint('Audio load failed: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  Future<void> _toggleCurrentTrack() async {
    await _handlePlay(_currentTrack);
  }

  Future<void> _seekTo(Duration position) async {
    final maxDuration = _totalDuration.inMilliseconds > 0
        ? _totalDuration
        : Duration(seconds: _currentTrack.durationSeconds ?? 0);

    final clamped = position < Duration.zero
        ? Duration.zero
        : position > maxDuration
        ? maxDuration
        : position;

    await _player.seek(clamped);

    if (!mounted) return;

    setState(() => _currentPosition = clamped);
  }

  void _openFullPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullPlayer(
          track: _currentTrack,
          player: _player,
          onPlayPause: _toggleCurrentTrack,
          onSeek: _seekTo,
        ),
      ),
    );
  }

  List<Widget> _buildScreens() => [
    HomeScreen(onTrackTap: _handlePlay),
    FeedScreen(onTrackTap: _handlePlay),
    SearchScreen(),
    LibraryScreen(
      onNavigate: _pushSubScreen,
      onBack: _popSubScreen,
      onTrackTap: _handlePlay,
    ),
    const UpgradeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // 🔥 Wait for bootstrap (prevent flicker)
    if (!_bootstrapped) {
      Future.microtask(() {
        if (mounted) setState(() => _bootstrapped = true);
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authState.isLoggedIn) {
      return const WelcomeScreen();
    }

    return Scaffold(
      body: _subScreens[_selectedIndex] ?? _buildScreens()[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            track: _currentTrack,
            isPlaying: _isPlaying,
            onPlay: _toggleCurrentTrack,
            onOpenFullPlayer: _openFullPlayer,
          ),
          BottomNavBar(
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
                _subScreens.remove(index);
              });
            },
          ),
        ],
      ),
    );
  }
}
