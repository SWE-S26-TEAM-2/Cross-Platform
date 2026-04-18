import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/conversation.dart';
import 'package:my_project/screens/home/chat_screen.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/messages_provider.dart';
import '../../models/notification.dart' as model;

class Activity extends ConsumerStatefulWidget {
  const Activity({super.key});

  @override
  ConsumerState<Activity> createState() => _ActivityState();
}

class _ActivityState extends ConsumerState<Activity> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final conversationsAsync = ref.watch(conversationsProvider);

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
            child: selectedTab == 0
                ? notificationsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _buildError(e.toString()),
                    data: (_) => _buildNotifications(),
                  )
                : conversationsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _buildError(e.toString()),
                    data: (_) => _buildMessages(),
                  ),
          ),
        ],
      ),

      // ── NEW: FAB to start a new conversation ───────────────────────────────
      floatingActionButton: selectedTab == 1
          ? FloatingActionButton(
              onPressed: _showNewMessageSheet,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.edit_outlined, color: Colors.white),
            )
          : null,
    );
  }

  // ─── New message bottom sheet ──────────────────────────────────────────────

  void _showNewMessageSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text('New Message', style: AppTextStyles.heading1),
              const SizedBox(height: 16),

              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter user ID or username',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final participantId = controller.text.trim();
                    if (participantId.isEmpty) return;

                    Navigator.pop(ctx); // close sheet

                    try {
                      // POST /conversations — create or get
                      final conversationId = await ref
                          .read(messagingServiceProvider)
                          .createOrGetConversation(
                            participantId: participantId,
                          );

                      if (!mounted) return;

                      // Refresh conversation list
                      ref.read(conversationsProvider.notifier).refresh();

                      // Navigate to chat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversationId: conversationId,
                            participantName: participantId,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceAll('Exception: ', ''),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Start Conversation'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Tab ──────────────────────────────────────────────────────────────────

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

  // ─── Error ────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          Text(
            message.replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  Widget _buildNotifications() {
    final notifications = ref.watch(notificationsProvider).value ?? [];

    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 40, color: Colors.grey),
            SizedBox(height: 12),
            Text('No notifications yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
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

  Widget _buildNotificationTile(model.Notification notif) {
    return InkWell(
      onTap: () {
        ref.read(notificationsProvider.notifier).markAsRead(notif.id);
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
                    notif.createdAt ?? '',
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

  // ─── Messages ─────────────────────────────────────────────────────────────

  Widget _buildMessages() {
    final conversations = ref.watch(conversationsProvider).value ?? [];

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.message_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No messages yet', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showNewMessageSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('New Message'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final other = conversation.participants.isNotEmpty
            ? conversation.participants.first
            : null;
        return _buildMessageTile(conversation, other);
      },
    );
  }

  Widget _buildMessageTile(Conversation conversation, Participant? other) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation.conversationId,
              participantName: other?.displayName ?? 'Unknown',
              participantAvatar: other?.profilePicture,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: other?.profilePicture != null
                  ? NetworkImage(other!.profilePicture!)
                  : null,
              child: other?.profilePicture == null
                  ? const Icon(Icons.person)
                  : null,
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
                          other?.displayName ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to open conversation',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
