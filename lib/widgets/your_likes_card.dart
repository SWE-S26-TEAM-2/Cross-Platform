import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_colors.dart';
import '../models/track.dart';

class YourLikesCard extends StatelessWidget {
  final List<Track> tracks;
  const YourLikesCard({super.key, required this.tracks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMedium,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMedium,
            vertical: AppDimensions.spaceSmall,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B1A00), Color(0xFF2A1A1A), Color(0xFF111111)],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusMedium,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFF8B1A00),
                      size: 52,
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(
                        Icons.favorite_border,
                        color: AppColors.primary.withOpacity(0.9),
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              const Text(
                'Your likes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shuffle,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.spaceMedium,
            right: AppDimensions.spaceMedium,
            top: AppDimensions.spaceSmall,
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.spaceSmall,
            mainAxisSpacing: AppDimensions.spaceSmall,
            childAspectRatio: 2.8,
            children: tracks
                .map(
                  (track) =>
                      _TrackGridTile(title: track.title, artist: track.artist),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _TrackGridTile extends StatelessWidget {
  final String title;
  final String artist;
  const _TrackGridTile({required this.title, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.borderRadiusSmall),
              bottomLeft: Radius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Container(
              width: 52,
              height: double.infinity,
              color: const Color(0xFF2E2E2E),
              child: const Icon(
                Icons.music_note,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
