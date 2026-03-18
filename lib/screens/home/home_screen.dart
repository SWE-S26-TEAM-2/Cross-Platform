import 'package:flutter/material.dart';
import '../../constants/app_dimensions.dart';
import '../../mock_data/mock_tracks.dart';
import 'your_likes_card.dart';
import 'today_pick_card.dart';
import 'more_like_section.dart';
import 'albums_for_you_section.dart';
import 'discover_with_stations.dart';
import '../../mock_data/mock_albums.dart';
import '../../mock_data/mock_stations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceSmall),

            // ── Your Likes ──────────────────────────────────
            const YourLikesCard(tracks: MockTracks.likedTracks),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            // ── Today's Pick ────────────────────────────────
            TodayPickCard(
              track: MockTracks.hotTrack,
              onPlay: () {
                //To be Implemented
              },
            ),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            // ── More of what you like ───────────────────────
            const MoreLikeSection(
              sectionTitle: 'More of what you like',
              tracks: MockTracks.recommendedTracks,
            ),
            const SizedBox(height: AppDimensions.spaceLarge), //break
            // ── Mixed for you ───────────────────────────────
            const MoreLikeSection(
              sectionTitle: 'Mixed for You',
              tracks: MockTracks.likedTracks,
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
