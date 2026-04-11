import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/user.dart';
import '../../providers/notifications_provider.dart';

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
        final user = notifications[index];
        return _buildTile(user, Icons.notifications, showFollow: true);
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
        return _buildTile(user, Icons.message, showFollow: false);
      },
    );
  }

  Widget _buildTile(User user, IconData icon, {required bool showFollow}) {
    return InkWell(
      onTap: () {
        if (showFollow) {
          final id = int.tryParse(user.id ?? '');
          if (id != null) {
            ref.read(markNotificationAsReadProvider(id).future);
          }
        }
      },
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
                      Icon(icon, size: 18, color: AppColors.textMuted),
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

            if (showFollow)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Follow"),
              ),
          ],
        ),
      ),
    );
  }
}
