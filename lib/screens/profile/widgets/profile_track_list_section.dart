import 'package:flutter/material.dart';
import '../../../models/track.dart';

class ProfileTrackListSection extends StatelessWidget {
  const ProfileTrackListSection({
    super.key,
    required this.title,
    required this.tracks,
    this.showSeeAll = false,
    this.onSeeAllTap,
    this.onTrackTap,
    this.onMoreTap,
  });

  final String title;
  final List<Track> tracks;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Track>? onTrackTap;
  final ValueChanged<Track>? onMoreTap;

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatCount(int count) {
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
                  color: Colors.white,
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
                      color: Colors.grey[300],
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
          itemCount: tracks.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return GestureDetector(
              onTap: () => onTrackTap?.call(track),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: track.artworkUrlSafe.isNotEmpty
                        ? Image.network(
                            track.artworkUrlSafe,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _TrackThumbPlaceholder(),
                          )
                        : const _TrackThumbPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.046).clamp(14.0, 17.0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: (screenWidth * 0.04).clamp(13.0, 15.0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '▶ ${_formatCount(track.likeCount)} · ${_formatDuration(track.duration)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: (screenWidth * 0.037).clamp(12.0, 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onMoreTap?.call(track),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.more_horiz, color: Colors.white70),
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

class _TrackThumbPlaceholder extends StatelessWidget {
  const _TrackThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }
}
