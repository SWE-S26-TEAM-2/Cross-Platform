import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../models/track.dart';

class TodayPickCard extends StatelessWidget {
  final Track track;
  final void Function(Track)? onTrackTap;

  const TodayPickCard({super.key, required this.track, this.onTrackTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, //Algin Children Horizontally
        children: [
          const Text(
            "TODAY'S PICK",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceExtraSmall),
          const Text('Hot For You 🔥', style: AppTextStyles.heading1),
          const SizedBox(height: AppDimensions.spaceSmall),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusMedium,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceSmall),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall,
                        ),
                        child: track.artworkUrlSafe.isNotEmpty
                            ? Image.network(
                                track.artworkUrlSafe,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                headers: const {'User-Agent': 'Mozilla/5.0'},
                                errorBuilder: (_, __, ___) =>
                                    const _PlaceholderCover(),
                              )
                            : const _PlaceholderCover(),
                      ),
                      const SizedBox(width: AppDimensions.spaceSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: AppTextStyles.trackTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.artist,
                              style: AppTextStyles.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceSmall),
                      GestureDetector(
                        onTap: track != null
                            ? () => onTrackTap?.call(track)
                            : null,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.background,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceSmall,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${track.likeCount} people just liked this track',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.waveformInactive,
      child: const Icon(Icons.music_note, color: AppColors.textMuted, size: 32),
    );
  }
}
