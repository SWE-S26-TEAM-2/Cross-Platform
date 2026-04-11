import 'package:flutter/material.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/screens/home/activity.dart';
import '../../constants/app_dimensions.dart';
import '../../mock_data/mock_tracks.dart';
import 'your_likes_card.dart';
import 'today_pick_card.dart';
import 'more_like_section.dart';
import 'albums_for_you_section.dart';
import 'discover_with_stations.dart';
import '../../mock_data/mock_albums.dart';
import '../../mock_data/mock_stations.dart';
import '../../mock_data/mock_users.dart';

class HomeScreen extends StatelessWidget {
  final void Function(Track)? onTrackTap;
  const HomeScreen({super.key, this.onTrackTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Activity(messages: mockUsers ?? []),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Activity(messages: mockUsers ?? []),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceSmall),

            // ── Your Likes ──────────────────────────────────
            YourLikesCard(
              tracks: MockTracks.likedTracks,
              onTrackTap: onTrackTap,
            ),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            // ── Today's Pick ────────────────────────────────
            TodayPickCard(track: MockTracks.hotTrack, onTrackTap: onTrackTap),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            // ── More of what you like ───────────────────────
            MoreLikeSection(
              sectionTitle: 'More of what you like',
              tracks: MockTracks.recommendedTracks,
              onTrackTap: onTrackTap,
            ),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            // ── Mixed for you ───────────────────────────────
            MoreLikeSection(
              sectionTitle: 'Mixed for You',
              tracks: MockTracks.likedTracks,
              onTrackTap: onTrackTap, // 👈 add this
            ),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            const AlbumsForYouSection(
              sectionTitle: 'Albums for You',
              albums: MockAlbums.featuredAlbums,
            ),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            const DiscoverWithStations(
              sectionTitle: 'Discover With Stations',
              albums: MockStations.featuredStations,
            ),
          ],
        ),
      ),
      // bottomNavigationBar: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     MiniPlayer(
      //       onPlay: () {
      //         //to be implemented
      //       },
      //       track: MockTracks.recommendedTracks[0],
      //     ),
      //     BottomNavBar(),
      //   ],
      // ),
    );
  }
}
