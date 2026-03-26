import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    super.key,
    required this.user,
    this.onBackPressed,
    this.onMorePressed,
    this.onEditPressed,
    this.onShufflePressed,
    this.onPlayPressed,
  });

  final User user;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMorePressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onShufflePressed;
  final VoidCallback? onPlayPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final double horizontalPadding = (screenWidth * 0.04).clamp(14.0, 18.0);
    final double bannerHeight = (screenWidth * 0.31).clamp(118.0, 138.0);
    final double avatarRadius = (screenWidth * 0.115).clamp(42.0, 52.0);
    final double topButtonsSize = 36.0;
    final double nameFontSize = (screenWidth * 0.062).clamp(22.0, 28.0);
    final double infoFontSize = (screenWidth * 0.037).clamp(13.0, 16.0);
    final double playButtonSize = (screenWidth * 0.13).clamp(44.0, 52.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: bannerHeight,
              width: double.infinity,
              color: Colors.grey[600],
            ),
            Positioned(
              top: 12,
              left: horizontalPadding,
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                size: topButtonsSize,
                iconSize: 16,
                onTap: onBackPressed,
              ),
            ),
            Positioned(
              top: 12,
              right: horizontalPadding,
              child: _CircleIconButton(
                icon: Icons.more_horiz,
                size: topButtonsSize,
                iconSize: 20,
                onTap: onMorePressed,
              ),
            ),
            Positioned(
              left: horizontalPadding,
              bottom: -avatarRadius * 0.62,
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    (user.avatarUrl != null &&
                            user.avatarUrl.toString().isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                child:
                    (user.avatarUrl == null ||
                            user.avatarUrl.toString().isEmpty)
                        ? Icon(
                            Icons.person,
                            color: Colors.white,
                            size: avatarRadius,
                          )
                        : null,
              ),
            ),
          ],
        ),
        SizedBox(height: avatarRadius * 0.82),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.userName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if ((user.location ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  user.location ?? '',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: infoFontSize,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                '${user.followers ?? 0} Followers • ${user.following ?? 0} Following',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: infoFontSize,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    onPressed: onEditPressed,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.grey[300],
                      size: (screenWidth * 0.06).clamp(20.0, 24.0),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onShufflePressed,
                    icon: Icon(
                      Icons.shuffle,
                      color: Colors.grey[400],
                      size: (screenWidth * 0.06).clamp(20.0, 24.0),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: (screenWidth * 0.028).clamp(8.0, 12.0)),
                  GestureDetector(
                    onTap: onPlayPressed,
                    child: Container(
                      width: playButtonSize,
                      height: playButtonSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: (playButtonSize * 0.5).clamp(24.0, 28.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    this.onTap,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}