import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/providers/track_provider.dart';
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

// ─── Real track UUIDs for "Mixed for You" test ───────────────────────────────
const _mixedForYouIds = [
  '2e4279a0-58a0-4935-b35d-3023c1213779',
  '384d87e6-7c88-4b8c-9d12-ea85cf3c0524',
  '527008e4-1408-4b62-9980-30252f1f0d4a',
];

class HomeScreen extends ConsumerWidget {
  final void Function(Track)? onTrackTap;
  const HomeScreen({super.key, this.onTrackTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all 3 track providers
    final trackStates = _mixedForYouIds
        .map((id) => ref.watch(trackProvider(id)))
        .toList();

    final isLoading = trackStates.any((s) => s.isLoading);
    final errors = trackStates
        .where((s) => s.hasError)
        .map((s) => s.error.toString())
        .toList();
    final mixedTracks = trackStates
        .whereType<AsyncData<Track>>()
        .map((s) => s.value)
        .toList();

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
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Activity()),
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
            const SizedBox(height: AppDimensions.spaceLarge),

            // ── Today's Pick ────────────────────────────────
            TodayPickCard(track: MockTracks.hotTrack, onTrackTap: onTrackTap),
            const SizedBox(height: AppDimensions.spaceLarge),

            // ── More of what you like ───────────────────────
            MoreLikeSection(
              sectionTitle: 'More of what you like',
              tracks: MockTracks.recommendedTracks,
              onTrackTap: onTrackTap,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),

            // ── Mixed for You (real API data) ────────────────
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mixed for You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...errors.map(
                      (e) => Text(
                        e,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else if (mixedTracks.isNotEmpty)
              MoreLikeSection(
                sectionTitle: 'Mixed for You',
                tracks: mixedTracks,
                onTrackTap: onTrackTap,
              ),

            const SizedBox(height: AppDimensions.spaceLarge),

            // ── Albums for You ──────────────────────────────
            const AlbumsForYouSection(
              sectionTitle: 'Albums for You',
              albums: MockAlbums.featuredAlbums,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),

            // ── Discover With Stations ──────────────────────
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
