import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import 'package:my_project/screens/library/widgets/library_tile.dart';
import 'package:my_project/screens/library/widgets/track_tile.dart';
import 'package:my_project/screens/home/playlist_album_block.dart';
import 'package:my_project/screens/library/liked_tracks_screen.dart';
import 'package:my_project/screens/library/playlists_screen.dart';
import 'package:my_project/screens/profile/profile_screen.dart';
import 'package:my_project/screens/library/albums_screen.dart';
import 'package:my_project/screens/library/collections_screen.dart';
import 'package:my_project/screens/library/collections_details_mapper.dart';
import 'package:my_project/models/recently_played_item.dart';
import 'following_screen.dart';
import 'insights_screen.dart';
import 'uploads_screen.dart';
import 'history_screen.dart';
import 'recently_played_screen.dart';
import 'context_menu_sheet.dart';

class LibraryScreen extends StatelessWidget {
  final void Function(Widget) onNavigate;
  final VoidCallback? onBack;
  const LibraryScreen({super.key, required this.onNavigate, this.onBack});

  @override
  Widget build(BuildContext context) {
    final history = MockTracks.historyTracks;

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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
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
          // ── Library menu tiles ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.spaceMedium),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                LibraryTile(
                  title: 'Liked Tracks',
                  onTap: () => onNavigate(LikedTracksScreen(onBack: onBack)),
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(
                  title: 'Playlists',
                  onTap: () => onNavigate(PlaylistsScreen(onBack: onBack)),
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(
                  title: 'Albums',
                  onTap: () => onNavigate(AlbumsScreen(onBack: onBack)),
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(
                  title: 'Following',
                  onTap: () => onNavigate(FollowingScreen(onBack: onBack)),
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(
                  title: 'Your insights',
                  onTap: () => onNavigate(InsightsScreen(onBack: onBack)),
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                LibraryTile(
                  title: 'Your uploads',
                  onTap: () => onNavigate(UploadsScreen(onBack: onBack)),
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge),
          ),

          // ── Recently Played header ───────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Recently Played',
              onSeeAll: () => onNavigate(RecentlyPlayedScreen(onBack: onBack)),
            ),
          ),

          // ── Recently Played — playlist/album horizontal boxes ────────
          SliverToBoxAdapter(
            child: PlaylistAlbumBlock(
              sectionTitle: '',
              items: MockTracks.recentlyPlayedItems,
              onItemTap: (item) => switch (item) {
                RecentlyPlayedPlaylist(:final playlist) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CollectionDetailsScreen(
                      data: CollectionDetailsMapper.fromPlaylist(playlist),
                    ),
                  ),
                ),
                RecentlyPlayedAlbum(:final album) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CollectionDetailsScreen(
                      data: CollectionDetailsMapper.fromAlbum(album),
                    ),
                  ),
                ),
              },
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge),
          ),

          // ── History header ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'History',
              onSeeAll: () => onNavigate(HistoryScreen(onBack: onBack)),
            ),
          ),

          // ── History — track tiles ────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => TrackTile(
                track: history[index],
                onTap: () {},
                onMoreTap: () => showTrackContextMenu(context, history[index]),
              ),
              childCount: history.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Section header with "See all" button ────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
        vertical: AppDimensions.spaceSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.heading2),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: AppTextStyles.artistName.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
