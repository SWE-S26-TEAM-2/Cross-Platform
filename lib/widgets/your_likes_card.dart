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
                //This sized box is teh the heart emoji (Shape + Border)
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
              const Spacer(), //Like Flex in CSSS
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
                  onPressed: () {}, // To be implemented
                ),
              ),
            ],
          ),
        ),

        Padding(
          //Like Column and Row but has Gridview (Square like shape)
          padding: const EdgeInsets.only(
            left: AppDimensions.spaceMedium,
            right: AppDimensions.spaceMedium,
            top: AppDimensions.spaceSmall,
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap:
                true, //Throws an error if removed (Grid try to fill the whole page although it is inside a colums)
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.spaceSmall,
            mainAxisSpacing: AppDimensions.spaceSmall,
            childAspectRatio: 2.8,
            children: [
              for (final track in tracks)
                _TrackGridTile(title: track.title, artist: track.artist),
            ],
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
            //Container but it can cut parts of burders (To have smooth top left and bottom right corners but hsarp at the right half )
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
          const SizedBox(width: AppDimensions.spaceSmall), //BReak
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
