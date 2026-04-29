import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';

/// Base tile for all media types (Track, Album, Playlist, Station).
/// Not used directly — extend it and override [leading], [title],
/// [subtitle], and optionally [meta].
abstract class TypeTile extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const TypeTile({super.key, this.onTap, this.onMoreTap});

  /// 52×52 artwork widget (image + fallback).
  Widget get leading;

  /// Primary label.
  String get title;

  /// Secondary label (artist, owner, platform…).
  String get subtitle;

  /// Optional third row (duration, track count, year…).
  /// Return null to omit.
  Widget? get meta => null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceSmall,
          horizontal: AppDimensions.spaceMedium,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusSmall,
              ),
              child: SizedBox(width: 52, height: 52, child: leading),
            ),

            const SizedBox(width: AppDimensions.spaceMedium),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.trackTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meta != null) ...[const SizedBox(height: 2), meta!],
                ],
              ),
            ),

            // More button
            IconButton(
              onPressed: onMoreTap,
              icon: const Icon(Icons.more_horiz),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers (used by all sub-tiles)
// ─────────────────────────────────────────────────────────────────────────────

/// Dot-separated metadata row: e.g. "Playlist · 17 tracks · 49:02"
class TileMeta extends StatelessWidget {
  final List<String> parts;
  const TileMeta(this.parts, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      parts.where((p) => p.isNotEmpty).join(' · '),
      style: AppTextStyles.artistName.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Network image with a dark placeholder fallback.
class TileArtwork extends StatelessWidget {
  final String? url;
  final IconData placeholderIcon;

  const TileArtwork({
    super.key,
    required this.url,
    this.placeholderIcon = Icons.music_note,
  });

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    color: AppColors.surface,
    child: Center(
      child: Icon(placeholderIcon, color: AppColors.textSecondary, size: 24),
    ),
  );
}
