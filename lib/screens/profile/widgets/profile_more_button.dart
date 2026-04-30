import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/user.dart';
import 'profile_view_info.dart';

/// Shows the ··· sheet as a full-screen modal.
/// Usage:
///   showProfileMoreSheet(context, user: user);
void showProfileMore(BuildContext context, {required User user}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (__, scrollController) =>
          ProfileMoreButton(user: user, scrollController: scrollController),
    ),
  );
}

class ProfileMoreButton extends StatelessWidget {
  const ProfileMoreButton({
    super.key,
    required this.user,
    this.scrollController,
  });

  final User user;
  final ScrollController? scrollController;

  static const Color _bg = Color(0xFF111111);
  static const Color _divider = Color(0xFF232323);

  // Correct order from screenshot:
  // Copy link, Message, QR code, SMS, WhatsApp, Stories, Snapchat, More
  List<_ShareItem> get _shareItems => [
    _ShareItem.dark(icon: Icons.copy_rounded, label: 'Copy link'),
    _ShareItem.dark(icon: Icons.near_me_outlined, label: 'Message'),
    _ShareItem.dark(icon: Icons.qr_code_2_rounded, label: 'QR code'),
    _ShareItem.dark(icon: Icons.chat_bubble_outline_rounded, label: 'SMS'),
    _ShareItem.whatsapp(),
    _ShareItem.instagram(),
    _ShareItem.snapchat(),
    _ShareItem.dark(icon: Icons.more_horiz_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 38.0;

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage:
                    (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? Icon(
                        Icons.person,
                        color: Colors.white54,
                        size: avatarRadius,
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                user.userName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Followers
              Text(
                '${_formatCount(user.followers ?? 0)} followers',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Share icons row
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _shareItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = _shareItems[index];
                    return _ShareIconButton(
                      item: item,
                      onTap: () => _handleTap(context, item.label),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              Divider(color: _divider, height: 1),

              // View info row
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  showProfileViewInfo(context, user: user);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'View info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, String label) {
    if (label == 'Copy link') {
      final url = 'https://soundcloud.com/${user.userName ?? ''}';
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      final v = count / 1000000;
      return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      final v = count / 1000;
      return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// ── Share item data model ────────────────────────────────────────────────────

enum _ShareItemType { dark, whatsapp, instagram, snapchat }

class _ShareItem {
  final String label;
  final _ShareItemType type;
  final IconData? icon;

  const _ShareItem._({required this.label, required this.type, this.icon});

  factory _ShareItem.dark({required IconData icon, required String label}) =>
      _ShareItem._(label: label, type: _ShareItemType.dark, icon: icon);

  factory _ShareItem.whatsapp() =>
      const _ShareItem._(label: 'WhatsApp', type: _ShareItemType.whatsapp);

  factory _ShareItem.instagram() =>
      const _ShareItem._(label: 'Stories', type: _ShareItemType.instagram);

  factory _ShareItem.snapchat() =>
      const _ShareItem._(label: 'Snapchat', type: _ShareItemType.snapchat);
}

// ── Share icon button ────────────────────────────────────────────────────────

class _ShareIconButton extends StatelessWidget {
  const _ShareIconButton({required this.item, required this.onTap});

  final _ShareItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircle(),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle() {
    switch (item.type) {
      case _ShareItemType.dark:
        return Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFF2A2A2A),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: Colors.white, size: 24),
        );

      case _ShareItemType.whatsapp:
        return Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFF25D366),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'W',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

      case _ShareItemType.instagram:
        return Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFFF58529),
                Color(0xFFDD2A7B),
                Color(0xFF8134AF),
                Color(0xFF515BD4),
              ],
            ),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
            size: 26,
          ),
        );

      case _ShareItemType.snapchat:
        return Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFC00),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.black,
            size: 24,
          ),
        );
    }
  }
}
