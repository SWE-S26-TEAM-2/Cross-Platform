import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../mock_data/mock_tracks.dart';
import '../../models/recently_played_item.dart';
import '../library/widgets/playlist_tile.dart';
import '../library/widgets/album_tile.dart';
import '../library/collections_details_mapper.dart';
import '../library/collections_screen.dart';
import '../../constants/app_text_styles.dart';
import 'context_menu_sheet.dart';

class RecentlyPlayedScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const RecentlyPlayedScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final items = MockTracks.recentlyPlayedItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Recently played', style: AppTextStyles.heading2),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Nothing played recently.',
                style: AppTextStyles.artistName,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _RecentlyPlayedTile(item: items[index]),
            ),
    );
  }
}

class _RecentlyPlayedTile extends StatelessWidget {
  final RecentlyPlayedItem item;

  const _RecentlyPlayedTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      RecentlyPlayedPlaylist(:final playlist) => PlaylistTile(
        playlist: playlist,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectionDetailsScreen(
              data: CollectionDetailsMapper.fromPlaylist(playlist),
            ),
          ),
        ),
        onMoreTap: () => showCollectionContextMenu(context),
      ),
      RecentlyPlayedAlbum(:final album) => AlbumTile(
        album: album,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectionDetailsScreen(
              data: CollectionDetailsMapper.fromAlbum(album),
            ),
          ),
        ),
        onMoreTap: () => showCollectionContextMenu(context),
      ),
    };
  }
}
