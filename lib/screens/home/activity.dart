import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/user.dart';

class Activity extends StatefulWidget {
  final List<User> notifications;
  final List<User> messages;

  const Activity({
    super.key,
    required this.notifications,
    required this.messages,
  });

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
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
            child: selectedTab == 0 ? _buildNotifications() : _buildMessages(),
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
    if (widget.notifications.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return ListView.separated(
      itemCount: widget.notifications.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final user = widget.notifications[index];

        return _buildTile(user, Icons.notifications);
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

        return _buildTile(user, Icons.message);
      },
    );
  }

  Widget _buildTile(User user, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icon(icon, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.userName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Follow"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
