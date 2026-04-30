import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/providers/library_providers.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import 'package:my_project/screens/library/widgets/library_tile.dart';
import 'package:my_project/screens/library/widgets/track_tile.dart';
import 'package:my_project/screens/library/liked_tracks_screen.dart';
import 'package:my_project/screens/library/playlists_screen.dart';
import 'package:my_project/screens/profile/profile_screen.dart';
import 'package:my_project/screens/library/albums_screen.dart';
import 'following_screen.dart';
import 'insights_screen.dart';
import 'uploads_screen.dart';
import 'history_screen.dart';
import 'recently_played_screen.dart';
import 'context_menu_sheet.dart';

class LibraryScreen extends ConsumerWidget {
  final void Function(Widget) onNavigate;
  final VoidCallback? onBack;
  final Future<void> Function(Track track) onTrackTap;

  const LibraryScreen({
    super.key,
    required this.onNavigate,
    this.onBack,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedAsync = ref.watch(recentlyPlayedProvider);
    final historyAsync = ref.watch(listeningHistoryProvider);

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
                  onTap: () => onNavigate(
                    PlaylistsScreen(
                      onBack: onBack,
                      onTrackTap: onTrackTap,
                      onNavigate: onNavigate,
                    ),
                  ),
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
                  onTap: () => onNavigate(
                    UploadsScreen(onBack: onBack, onTrackTap: onTrackTap),
                  ),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge),
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Recently Played',
              onSeeAll: () => onNavigate(RecentlyPlayedScreen(onBack: onBack)),
            ),
          ),
          SliverToBoxAdapter(
            child: recentlyPlayedAsync.when(
              loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (tracks) => tracks.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMedium,
                        vertical: AppDimensions.spaceSmall,
                      ),
                      child: Text(
                        'Nothing played recently.',
                        style: AppTextStyles.artistName,
                      ),
                    )
                  : _TrackHorizontalScroll(
                      tracks: tracks,
                      onTrackTap: onTrackTap,
                    ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge),
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'History',
              onSeeAll: () => onNavigate(HistoryScreen(onBack: onBack)),
            ),
          ),
          historyAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (tracks) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TrackTile(
                  track: tracks[index],
                  onTap: () => onTrackTap(tracks[index]),
                  onMoreTap: () => showTrackContextMenu(context, tracks[index]),
                ),
                childCount: tracks.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _TrackHorizontalScroll extends StatelessWidget {
  final List<Track> tracks;
  final Future<void> Function(Track) onTrackTap;

  const _TrackHorizontalScroll({
    required this.tracks,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMedium,
        ),
        child: Row(
          children: [
            for (int i = 0; i < tracks.length; i++) ...[
              GestureDetector(
                onTap: () => onTrackTap(tracks[i]),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall,
                        ),
                        child: (tracks[i].coverImageUrl?.isNotEmpty ?? false)
                            ? Image.network(
                                tracks[i].coverImageUrl!,
                                width: 150,
                                height: 130,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const _PlaceholderThumb(),
                              )
                            : const _PlaceholderThumb(),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tracks[i].title,
                        style: AppTextStyles.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        tracks[i].formattedArtist,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (i < tracks.length - 1)
                const SizedBox(width: AppDimensions.spaceSmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 130,
      color: AppColors.waveformInactive,
      child: const Icon(
        Icons.queue_music,
        color: AppColors.textMuted,
        size: 40,
      ),
    );
  }
}

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
