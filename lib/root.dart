import 'dart:async';

import 'package:flutter/material.dart';
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

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
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
      setState(() {
        _currentPosition = position;
      });
    });

    _durationSub = _player.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() {
        _totalDuration = duration ?? Duration(seconds: _currentTrack.duration);
      });
    });

    _playerStateSub = _player.playerStateStream.listen((playerState) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playerState.playing;
      });
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
    if (track.audioPath.isEmpty) return;

    if (_currentTrack.id == track.id && _isPlaying) {
      await _player.pause();
      return;
    }

    if (_currentTrack.id != track.id || !_hasLoaded) {
      _hasLoaded = true;
      _currentTrack = track;
      _currentPosition = Duration.zero;
      _totalDuration = Duration(seconds: track.duration);

      await _player.setAsset(track.audioPath);
    }

    await _player.play();

    if (!mounted) return;
    setState(() {
      _currentTrack = track;
    });
  }

  Future<void> _toggleCurrentTrack() async {
    await _handlePlay(_currentTrack);
  }

  Future<void> _seekTo(Duration position) async {
    final maxDuration = _totalDuration.inMilliseconds > 0
        ? _totalDuration
        : Duration(seconds: _currentTrack.duration);

    Duration clamped = position;

    if (clamped < Duration.zero) {
      clamped = Duration.zero;
    } else if (clamped > maxDuration) {
      clamped = maxDuration;
    }

    await _player.seek(clamped);

    if (!mounted) return;
    setState(() {
      _currentPosition = clamped;
    });
  }

  void _openFullPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullPlayer(
          track: _currentTrack,
          isPlaying: _isPlaying,
          currentPosition: _currentPosition,
          totalDuration: _totalDuration.inMilliseconds > 0
              ? _totalDuration
              : Duration(seconds: _currentTrack.duration),
          onPlayPause: _toggleCurrentTrack,
          onSeek: _seekTo,
        ),
      ),
    );
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
            onPlay: _toggleCurrentTrack,
            onOpenFullPlayer: _openFullPlayer,
          ),
          BottomNavBar(
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}