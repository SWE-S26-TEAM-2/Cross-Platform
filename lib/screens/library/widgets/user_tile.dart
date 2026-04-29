import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';

class UserTile extends StatefulWidget {
  final String? avatarUrl;
  final String? userName;
  final String? location;
  final int? followers;
  final bool isFollowing;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onTap;

  const UserTile({
    super.key,
    this.avatarUrl,
    this.userName,
    this.location,
    this.followers,
    this.isFollowing = true,
    this.onNotificationTap,
    this.onTap,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
  }

  String get _formattedFollowers {
    if (widget.followers == null) return '';
    final n = widget.followers!;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M Followers';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K Followers';
    return '$n Followers';
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMedium,
          vertical: AppDimensions.spaceExtraLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimensions.spaceLarge),
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 56,
            ),

            const SizedBox(height: AppDimensions.spaceLarge),

            const Text(
              'Turn on notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppDimensions.spaceSmall),

            const Text(
              'Never miss an update from your favorite artists.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),

            const SizedBox(height: AppDimensions.spaceExtraLarge),

            // Enable button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // hook up actual notification permission later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusPill,
                    ),
                  ),
                ),
                child: const Text(
                  'Enable notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceMedium),

            // Maybe later
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Maybe later',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceSmall,
          horizontal: AppDimensions.spaceMedium,
        ),
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────────────
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.surface,
              backgroundImage:
                  (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                  ? const Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 28,
                    )
                  : null,
            ),

            const SizedBox(width: AppDimensions.spaceMedium),

            // ── Username + location + followers ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.userName ?? 'Unknown',
                    style: AppTextStyles.trackTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.location!,
                      style: AppTextStyles.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (widget.followers != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formattedFollowers,
                          style: AppTextStyles.artistName,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: AppDimensions.spaceSmall),

            // ── Follow / Following toggle ─────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _isFollowing = !_isFollowing),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMedium,
                  vertical: AppDimensions.spaceSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusPill,
                  ),
                ),
                child: Text(
                  _isFollowing ? 'Following' : 'Follow',
                  style: AppTextStyles.trackTitle.copyWith(fontSize: 13),
                ),
              ),
            ),

            const SizedBox(width: AppDimensions.spaceSmall),

            // ── Notification bell ────────────────────────────────────
            GestureDetector(
              onTap: _showNotificationsSheet,
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
