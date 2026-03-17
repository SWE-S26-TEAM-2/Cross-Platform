import 'package:flutter/material.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import 'package:my_project/widgets/mini_player.dart';
import 'package:my_project/navigation/bottom_nav_bar.dart';
import 'package:my_project/screens/home/home_screen.dart';
import 'package:my_project/screens/home/temp_feed_screen.dart';
import 'package:my_project/screens/home/temp_search_screen.dart';
import 'package:my_project/screens/home/temp_library_screen.dart';
import 'package:my_project/screens/home/temp_upgrade_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TempFeedScreen(),
    const TempSearchScreen(),
    const TempLibraryScreen(),
    const TempUpgradeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(track: MockTracks.hotTrack, onPlay: () {}),
          BottomNavBar(
            onTabSelected: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ),
    );
  }
}
