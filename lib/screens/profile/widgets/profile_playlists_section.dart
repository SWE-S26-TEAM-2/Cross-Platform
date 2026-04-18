import 'package:flutter/material.dart';
import '../../../models/track.dart';

class ProfilePlaylistsSection extends StatelessWidget {
  const ProfilePlaylistsSection({
    super.key,
    required this.title,
    required this.tracks,
    this.onTrackTap,
  });

  final String title;
  final List<Track> tracks;
  final ValueChanged<Track>? onTrackTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = (screenWidth * 0.04).clamp(14.0, 18.0);
    final double cardWidth = (screenWidth * 0.26).clamp(96.0, 128.0);
    final double imageSize = cardWidth;
    final double sectionTitleFontSize = (screenWidth * 0.055).clamp(17.0, 21.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: sectionTitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: imageSize + 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: tracks.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return GestureDetector(
                onTap: () => onTrackTap?.call(track),
                child: SizedBox(
                  width: cardWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: track.artworkUrlSafe.isNotEmpty
                            ? Image.network(
                                track.artworkUrlSafe,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return _PlaylistPlaceholder(size: imageSize);
                                },
                              )
                            : _PlaylistPlaceholder(size: imageSize),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (screenWidth * 0.038).clamp(12.0, 14.0),
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: (screenWidth * 0.032).clamp(10.0, 12.0),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlaylistPlaceholder extends StatelessWidget {
  const _PlaylistPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.queue_music, color: Colors.white54, size: 30),
    );
  }
}
