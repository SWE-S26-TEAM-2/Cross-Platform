import 'package:flutter/material.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_colors.dart';
import '../../models/recently_played_item.dart';
import '../../models/playlist.dart';
import '../../models/album.dart';
import 'more_like_section.dart';

class PlaylistAlbumBlock extends StatelessWidget {
  final String sectionTitle;
  final List<RecentlyPlayedItem> items;
  final void Function(RecentlyPlayedItem)? onItemTap;

  const PlaylistAlbumBlock({
    super.key,
    required this.sectionTitle,
    required this.items,
    this.onItemTap,
  });

  String _coverUrl(RecentlyPlayedItem item) => switch (item) {
    RecentlyPlayedPlaylist(:final playlist) => playlist.coverUrl ?? '',
    RecentlyPlayedAlbum(:final album) => album.artworkUrl,
  };

  String _title(RecentlyPlayedItem item) => switch (item) {
    RecentlyPlayedPlaylist(:final playlist) => playlist.name,
    RecentlyPlayedAlbum(:final album) => album.title,
  };

  String _subtitle(RecentlyPlayedItem item) => switch (item) {
    RecentlyPlayedPlaylist(:final playlist) => playlist.owner,
    RecentlyPlayedAlbum(:final album) => album.artist,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMedium,
            ),
            child: Text(sectionTitle, style: AppTextStyles.heading1),
          ),
        if (sectionTitle.isNotEmpty)
          const SizedBox(height: AppDimensions.spaceSmall),
        SizedBox(
          height: 180,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMedium,
            ),
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  GestureDetector(
                    onTap: () => onItemTap?.call(items[i]),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSmall,
                            ),
                            child: _coverUrl(items[i]).isNotEmpty
                                ? Image.network(
                                    _coverUrl(items[i]),
                                    width: 150,
                                    height: 130,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const _PlaceholderThumb(),
                                  )
                                : const _PlaceholderThumb(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _title(items[i]),
                            style: AppTextStyles.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _subtitle(items[i]),
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < items.length - 1)
                    const SizedBox(width: AppDimensions.spaceSmall),
                ],
              ],
            ),
          ),
        ),
      ],
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
