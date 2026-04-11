import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/notification.dart';
import 'package:my_project/models/user.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification.dart' as model;

class Activity extends ConsumerStatefulWidget {
  final List<User> messages;

  const Activity({super.key, required this.messages});

  @override
  ConsumerState<Activity> createState() => _ActivityState();
}

class _ActivityState extends ConsumerState<Activity> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(getNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Activity')),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(child: _buildTab(label: 'Notifications', index: 0)),
                Expanded(child: _buildTab(label: 'Messages', index: 1)),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.divider),

          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (_) =>
                  selectedTab == 0 ? _buildNotifications() : _buildMessages(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({required String label, required int index}) {
    final bool isActive = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMedium,
          vertical: AppDimensions.spaceSmall,
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: isActive ? AppColors.primary : AppColors.textMuted,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    final notifications = ref.watch(getNotificationsProvider).value ?? [];

    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return _buildNotificationTile(notif);
      },
    );
  }

  Widget _buildMessages() {
    if (widget.messages.isEmpty) {
      return const Center(child: Text('No messages'));
    }

    return ListView.separated(
      itemCount: widget.messages.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final user = widget.messages[index];
        return _buildMessageTile(user);
      },
    );
  }

  Widget _buildNotificationTile(model.Notification notif) {
    return InkWell(
      onTap: () {
        final id = int.tryParse(notif.id);
        if (id != null) {
          ref.read(markNotificationAsReadProvider(id).future);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(radius: 22, child: Icon(_iconForType(notif.type))),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.message,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.createdAt,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            if (!notif.isRead)
              const CircleAvatar(radius: 5, backgroundColor: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(User user) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null ? const Icon(Icons.person) : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.message,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.userName ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap to view details",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'follow':
        return Icons.person_add;
      case 'comment':
        return Icons.comment;
      case 'repost':
        return Icons.repeat;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
}
