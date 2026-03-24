import 'package:flutter/material.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/screens/search/search_screen.dart';
import 'package:my_project/screens/upgrade/upgrade_screen.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/navigation/bottom_nav_bar.dart';
import 'package:my_project/screens/home/home_screen.dart';
import 'package:my_project/screens/home/temp_feed_screen.dart';
import 'package:my_project/screens/home/temp_library_screen.dart';
import 'package:my_project/screens/home/temp_upgrade_screen.dart';
import 'package:just_audio/just_audio.dart';

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
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   // runs once when screen first opens
  //   super.initState();
  //   _initPlayer(); // calls your preload function
  // }

  // Future<void> _initPlayer() async {
  //   await _player.setAsset(
  //     MockTracks.hotTrack.audioPath,
  //   ); // s preloads the audio
  // }

  Future<void> _handlePlay(Track track) async {
    print('=== HANDLE PLAY CALLED ===');
    print('Track: ${track.title}');
    print('Path: ${track.audioPath}');

    if (track.audioPath.isEmpty) {
      print('=== PATH IS EMPTY, RETURNING ===');
      return;
    }

    print('=== CALLING PLAYER ===');

    if (_currentTrack.id == track.id && _isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      print('=== PLAYER PAUSED ===');
    } else {
      if (_currentTrack.id != track.id || !_hasLoaded) {
        _hasLoaded = true;
        await _player.setAsset(track.audioPath);
        print('=== NEW TRACK LOADED ===');
      }
      _player.play();

      ///Without await as the .play was waiting for the entire song to finish
      setState(() {
        _currentTrack = track;
        _isPlaying = true;
      });
      print('=== PLAYER PLAYING ===');
    }
  }

  List<Widget> _buildScreens() => [
    // 0
    const HomeScreen(),

    /// 1
    const TempFeedScreen(),

    /// 2
    const SearchScreen(),

    /// 3
    const TempLibraryScreen(),

    /// 4
    const UpgradeScreen(),
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreens()[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            track: _currentTrack,
            isPlaying: _isPlaying,
            onPlay: () => _handlePlay(_currentTrack!),
          ),
          BottomNavBar(
            onTabSelected: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ),
    );
  }
}
