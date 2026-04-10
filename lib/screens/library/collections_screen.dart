import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

enum CollectionType {
  playlist,
  album,
  station,
}

class CollectionTrack {
  final String title;
  final String artist;
  final String? secondaryArtist;
  final String artworkPath;
  final bool isAvailable;

  const CollectionTrack({
    required this.title,
    required this.artist,
    this.secondaryArtist,
    required this.artworkPath,
    this.isAvailable = true,
  });
}

class CollectionDetailsData {
  final CollectionType type;
  final String title;
  final String artworkPath;
  final String ownerName;
  final String ownerAvatarPath;
  final String yearText;
  final String likesText;
  final List<CollectionTrack> tracks;

  const CollectionDetailsData({
    required this.type,
    required this.title,
    required this.artworkPath,
    required this.ownerName,
    required this.ownerAvatarPath,
    required this.yearText,
    required this.likesText,
    required this.tracks,
  });
}

class CollectionDetailsScreen extends StatelessWidget {
  final CollectionDetailsData data;

  const CollectionDetailsScreen({
    super.key,
    required this.data,
  });

  String get _typeLabel {
    switch (data.type) {
      case CollectionType.playlist:
        return 'Playlist';
      case CollectionType.album:
        return 'Album';
      case CollectionType.station:
        return 'Station';
    }
  }

  String get _metaText {
    return '${data.yearText} • $_typeLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                children: [
                  _TopSection(data: data, metaText: _metaText),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  _ActionRow(likesText: data.likesText),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  ...List.generate(
                    data.tracks.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index == data.tracks.length - 1
                            ? 0
                            : AppDimensions.spaceMedium,
                      ),
                      child: _TrackTile(
                        track: data.tracks[index],
                      ),
                    ),
                  ),

                  /// Extra space for mini-player + bottom nav
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  final CollectionDetailsData data;
  final String metaText;

  const _TopSection({
    required this.data,
    required this.metaText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusMedium,
              ),
              child: Image.asset(
                data.artworkPath,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metaText,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(data.ownerAvatarPath),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'By ${data.ownerName}',
                          style: AppTextStyles.trackTitle.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String likesText;

  const _ActionRow({
    required this.likesText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.favorite_border,
          color: Colors.white70,
          size: 30,
        ),
        const SizedBox(width: 8),
        Text(
          likesText,
          style: AppTextStyles.trackTitle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 16),
        const Icon(
          Icons.more_horiz,
          color: Colors.white70,
          size: 28,
        ),
        const Spacer(),
        const Icon(
          Icons.shuffle,
          color: Colors.white70,
          size: 30,
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.black,
            size: 40,
          ),
        ),
      ],
    );
  }
}

class _TrackTile extends StatelessWidget {
  final CollectionTrack track;

  const _TrackTile({
    required this.track,
  });

  String get _artistLine {
    if (track.secondaryArtist == null || track.secondaryArtist!.trim().isEmpty) {
      return track.artist;
    }
    return '${track.artist}, ${track.secondaryArtist}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusMedium,
          ),
          child: Image.asset(
            track.artworkPath,
            width: 74,
            height: 74,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.trackTitle.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _artistLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              if (!track.isAvailable) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_off,
                      color: Colors.white60,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Not available',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white60,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.more_horiz,
          color: Colors.white70,
          size: 26,
        ),
      ],
    );
  }
}