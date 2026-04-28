import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../main.dart' show kUseMockAuth;
import '../../providers/auth_providers.dart';
import '../../services/mock_auth_service.dart';
import 'package:my_project/screens/home/more_like_section.dart';
import 'package:my_project/screens/library/library_tile.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    if (kUseMockAuth) {
      MockAuthService().logout();
    } else {
      await ref.read(authProvider.notifier).logout();
    }
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Library',
          style: AppTextStyles.heading2,
        ),
        actions: [
          IconButton(
            key: const Key('library.logout'),
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context, ref),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.spaceMedium,
            ),
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
            padding: const EdgeInsets.all(AppDimensions.spaceMedium),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  LibraryTile(
                    key: const Key('library.section.liked'),
                    title: 'Liked Tracks',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  LibraryTile(
                    key: const Key('library.section.playlists'),
                    title: 'Playlists',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  LibraryTile(
                    key: const Key('library.section.albums'),
                    title: 'Albums',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  LibraryTile(
                    key: const Key('library.section.following'),
                    title: 'Following',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  LibraryTile(
                    key: const Key('library.section.stations'),
                    title: 'Stations',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  LibraryTile(title: 'Your insights', onTap: () {}),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  LibraryTile(title: 'Your uploads', onTap: () {}),
                  const SizedBox(height: AppDimensions.spaceSmall),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge),
          ),
          SliverToBoxAdapter(
            child: MoreLikeSection(
              sectionTitle: 'Recently Played',
              tracks: MockTracks.recentlyPlayedTracks,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spaceLarge),
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
