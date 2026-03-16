import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../models/album.dart';

class AlbumsForYouSection extends StatelessWidget {
  final String sectionTitle;
  final List<Album> albums;
  final void Function(Album)? onAlbumTap;

  const AlbumsForYouSection({
    super.key,
    required this.sectionTitle,
    required this.albums,
    this.onAlbumTap,
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
          height: 210,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMedium,
            ),
            child: Row(
              children: [
                for (int i = 0; i < albums.length; i++) ...[
                  GestureDetector(
                    onTap: () => onAlbumTap?.call(albums[i]),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSmall,
                            ),
                            child: albums[i].artworkUrl.isNotEmpty
                                ? Image.network(
                                    albums[i].artworkUrl,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    headers: const {
                                      'User-Agent': 'Mozilla/5.0',
                                    },
                                    errorBuilder: (_, __, ___) =>
                                        const _PlaceholderCover(),
                                  )
                                : const _PlaceholderCover(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            albums[i].title,
                            style: AppTextStyles.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${albums[i].artist} · ${albums[i].trackCount} tracks',
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < albums.length - 1)
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

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      color: AppColors.waveformInactive,
      child: const Icon(Icons.album, color: AppColors.textMuted, size: 40),
    );
  }
}
