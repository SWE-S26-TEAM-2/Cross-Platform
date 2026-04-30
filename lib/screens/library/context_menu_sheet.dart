import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/track.dart';

// ── Entry point helpers ──────────────────────────────────────────────────────

void showTrackContextMenu(BuildContext context, Track track) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ContextMenuSheet.track(track: track),
  );
}

/// Used for albums and playlists — no track header, no queue actions.
void showCollectionContextMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ContextMenuSheet.collection(),
  );
}

// ── Sheet ────────────────────────────────────────────────────────────────────

class _ContextMenuSheet extends StatefulWidget {
  final Track? track;

  const _ContextMenuSheet.track({required Track this.track});
  const _ContextMenuSheet.collection() : track = null;

  bool get isTrack => track != null;

  @override
  State<_ContextMenuSheet> createState() => _ContextMenuSheetState();
}

class _ContextMenuSheetState extends State<_ContextMenuSheet> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Track header (track only) ────────────────────────
              if (widget.isTrack) _TrackHeader(track: widget.track!),

              // ── Scrollable content ───────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Share row ────────────────────────────────
                    _ShareRow(),

                    const _Divider(),

                    // ── Like ─────────────────────────────────────
                    _MenuItem(
                      icon: _liked ? Icons.favorite : Icons.favorite_border,
                      iconColor: _liked ? AppColors.primary : null,
                      label: _liked ? 'Liked' : 'Like',
                      labelColor: _liked ? AppColors.primary : null,
                      onTap: () => setState(() => _liked = !_liked),
                    ),

                    if (widget.isTrack) ...[
                      _MenuItem(
                        icon: Icons.queue_play_next,
                        label: 'Play next',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.add_to_queue,
                        label: 'Play last',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.playlist_add,
                        label: 'Add to playlist',
                        onTap: () {},
                      ),
                    ],

                    const _Divider(),

                    _MenuItem(
                      icon: Icons.person_outline,
                      label: 'Go to profile',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'View comments',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.repeat,
                      label: 'Repost on SoundCloud',
                      onTap: () {},
                    ),

                    const _Divider(),

                    _MenuItem(
                      icon: Icons.graphic_eq,
                      label: 'Behind this track',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.flag_outlined,
                      label: 'Report',
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Track header ─────────────────────────────────────────────────────────────

class _TrackHeader extends StatelessWidget {
  final Track track;
  const _TrackHeader({required this.track});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
        vertical: AppDimensions.spaceMedium,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceLight.withOpacity(0.8),
            AppColors.background,
          ],
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 72,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Vinyl disc
                Positioned(
                  right: -8,
                  top: 8,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: Colors.grey.shade800, width: 1),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                ),
                // Artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusSmall,
                  ),
                  child: (track.artworkUrl ?? '').isNotEmpty
                      ? Image.network(
                          track.artworkUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(72),
                        )
                      : _placeholder(72),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: AppTextStyles.heading2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(track.formattedArtist, style: AppTextStyles.artistName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(double size) => Container(
    width: size,
    height: size,
    color: AppColors.surfaceLight,
    child: const Icon(Icons.music_note, color: AppColors.textSecondary),
  );
}

// ── Share row ────────────────────────────────────────────────────────────────

class _ShareRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceMedium,
        AppDimensions.spaceMedium,
        AppDimensions.spaceMedium,
        AppDimensions.spaceSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHARE',
            style: AppTextStyles.artistName.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ShareButton(
                  icon: Icons.send_outlined,
                  label: 'Message',
                  onTap: () {},
                ),
                _ShareButton(
                  icon: Icons.copy_outlined,
                  label: 'Copy link',
                  onTap: () {},
                ),
                _ShareButton(
                  icon: Icons.qr_code_2,
                  label: 'QR code',
                  onTap: () {},
                ),
                _ShareButton(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: AppDimensions.spaceLarge),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.artistName.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Menu item ────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 22),
      title: Text(
        label,
        style: AppTextStyles.trackTitle.copyWith(
          color: labelColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

// ── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 0.5,
    color: AppColors.divider,
    indent: AppDimensions.spaceMedium,
    endIndent: AppDimensions.spaceMedium,
  );
}
