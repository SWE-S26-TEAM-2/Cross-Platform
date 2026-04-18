import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/screens/home/activity.dart';
import '../../constants/app_dimensions.dart';
import '../../mock_data/mock_tracks.dart';
import '../../providers/notifications_provider.dart';
import 'your_likes_card.dart';
import 'today_pick_card.dart';
import 'more_like_section.dart';
import 'albums_for_you_section.dart';
import 'discover_with_stations.dart';
import '../../mock_data/mock_albums.dart';
import '../../mock_data/mock_stations.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(Track)? onTrackTap;
  const HomeScreen({super.key, this.onTrackTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Activity()),
              );
            },
          ),
          Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Activity()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceSmall),
            YourLikesCard(
              tracks: MockTracks.likedTracks,
              onTrackTap: onTrackTap,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            TodayPickCard(track: MockTracks.hotTrack, onTrackTap: onTrackTap),
            const SizedBox(height: AppDimensions.spaceLarge),
            MoreLikeSection(
              sectionTitle: 'More of what you like',
              tracks: MockTracks.recommendedTracks,
              onTrackTap: onTrackTap,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            MoreLikeSection(
              sectionTitle: 'Mixed for You',
              tracks: MockTracks.likedTracks,
              onTrackTap: onTrackTap,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            const AlbumsForYouSection(
              sectionTitle: 'Albums for You',
              albums: MockAlbums.featuredAlbums,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            const DiscoverWithStations(
              sectionTitle: 'Discover With Stations',
              albums: MockStations.featuredStations,
            ),
          ],
        ),
      ),
    );
  }
}
