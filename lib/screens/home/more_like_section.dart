import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../models/track.dart';

class MoreLikeSection extends StatelessWidget {
  final String sectionTitle;
  final List<Track> tracks;
  final void Function(Track)? onTrackTap;

  const MoreLikeSection({
    super.key,
    required this.sectionTitle,
    required this.tracks,
    this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMedium,
          ),
          child: Text(sectionTitle, style: AppTextStyles.heading1),
        ),
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
                for (int i = 0; i < tracks.length; i++) ...[
                  GestureDetector(
                    onTap: () => onTrackTap?.call(tracks[i]),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSmall,
                            ),
                            child: tracks[i].artworkUrlSafe.isNotEmpty
                                ? Image.network(
                                    tracks[i].artworkUrlSafe,
                                    width: 150,
                                    height: 130,
                                    fit: BoxFit.cover,
                                    headers: const {
                                      'User-Agent': 'Mozilla/5.0',
                                    },
                                    errorBuilder: (_, __, ___) =>
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
                            tracks[i].artist,
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
