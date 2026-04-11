import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../../../../models/playlist.dart';

class PlaylistTiles extends StatelessWidget {
  const PlaylistTiles({
    super.key,
    required this.title,
    required this.playlists,
    this.showSeeAll = false,
    this.onSeeAllTap,
    this.onPlaylistTap,
    this.onMoreTap,
  });

  final String title;
  final List<Playlist> playlists;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Playlist>? onPlaylistTap;
  final ValueChanged<Playlist>? onMoreTap;

  String _formatTrackCount(int count) {
    if (count >= 1000000) {
      final value = count / 1000000;
      return value % 1 == 0
          ? '${value.toInt()}M'
          : '${value.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      final value = count / 1000;
      return value % 1 == 0
          ? '${value.toInt()}K'
          : '${value.toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = (screenWidth * 0.04).clamp(14.0, 18.0);
    final double titleFontSize = (screenWidth * 0.06).clamp(18.0, 22.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (showSeeAll)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: (screenWidth * 0.038).clamp(13.0, 15.0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          itemCount: playlists.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return GestureDetector(
              onTap: () => onPlaylistTap?.call(playlist),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cover art ────────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSharp,
                    ),
                    child: playlist.coverUrl.isNotEmpty
                        ? Image.network(
                            playlist.coverUrl,
                            width: AppDimensions.trackArtworkSmall,
                            height: AppDimensions.trackArtworkSmall,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _PlaylistCoverPlaceholder(),
                          )
                        : const _PlaylistCoverPlaceholder(),
                  ),
                  const SizedBox(width: AppDimensions.spaceMedium - 4),
                  // ── Text info ─────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: (screenWidth * 0.046).clamp(14.0, 17.0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            playlist.owner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: (screenWidth * 0.04).clamp(13.0, 15.0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Playlist · ${_formatTrackCount(playlist.trackCount)} tracks · ${playlist.duration}',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: (screenWidth * 0.037).clamp(12.0, 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  // ── More button ───────────────────────────────────────
                  GestureDetector(
                    onTap: () => onMoreTap?.call(playlist),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.more_horiz,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PlaylistCoverPlaceholder extends StatelessWidget {
  const _PlaylistCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.trackArtworkSmall,
      height: AppDimensions.trackArtworkSmall,
      color: AppColors.surfaceLight,
      child: const Icon(Icons.queue_music, color: AppColors.textSecondary),
    );
  }
}