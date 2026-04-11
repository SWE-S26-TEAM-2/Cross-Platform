import 'package:flutter/material.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import 'package:my_project/screens/home/more_like_section.dart';
import 'package:my_project/screens/library/library_tile.dart';
import 'package:my_project/screens/library/liked_tracks_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Library', style: AppTextStyles.heading2),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spaceMedium),

            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),

                const SizedBox(width: AppDimensions.spaceSmall),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: AppDimensions.avatarSizeSmall,
                    height: AppDimensions.avatarSizeSmall,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(AppDimensions.spaceMedium),

            sliver: SliverList(
              delegate: SliverChildListDelegate([
                LibraryTile(title: 'Liked Tracks', onTap: () {}),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(title: 'Playlists', onTap: () {}),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(title: 'Albums', onTap: () {}),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(title: 'Following', onTap: () {}),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(title: 'Stations', onTap: () {}),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(title: 'Your insights', onTap: () {}),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(title: 'Your uploads', onTap: () {}),
                const SizedBox(height: AppDimensions.spaceSmall),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge), //break
          ),

          SliverToBoxAdapter(
            child: MoreLikeSection(
              sectionTitle: 'Recently Played',
              tracks: MockTracks.recentlyPlayedTracks,
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge), //break
          ),

          SliverToBoxAdapter(
            child: MoreLikeSection(
              sectionTitle: 'History',
              tracks: MockTracks.historyTracks,
            ),
          ),
        ],
      ),
    );
  }
}
