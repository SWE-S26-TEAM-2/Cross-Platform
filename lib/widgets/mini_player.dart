import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/track.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.onPlay,
    required this.track,
    required this.isPlaying,
    required this.onOpenFullPlayer,
  });

  final VoidCallback? onPlay;
  final VoidCallback onOpenFullPlayer;
  final Track track;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenFullPlayer,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.spaceSmall,
          right: AppDimensions.spaceSmall,
          bottom: AppDimensions.spaceMedium,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceSmall),
          height: AppDimensions.miniPlayerBarHeight,
          decoration: const ShapeDecoration(
            color: AppColors.surface,
            shape: StadiumBorder(
              side: BorderSide(color: AppColors.textMuted, width: 1),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onPlay,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.all(AppDimensions.spaceExtraSmall),
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textPrimary,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.background,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, style: AppTextStyles.trackTitle),
                    Text(track.artist, style: AppTextStyles.artistName),
                  ],
                ),
              ),
              const Icon(Icons.phone_android),
              const SizedBox(width: AppDimensions.spaceSmall),
              const Icon(
                Icons.favorite_border,
                color: AppColors.textPrimary,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
            ],
          ),
        ),
      ),
    );
  }
}