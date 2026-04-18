import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/models/message.dart';
import 'package:my_project/providers/auth_providers.dart';
import '../../providers/messages_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;
  final String? participantAvatar;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      await ref
          .read(messagesProvider(widget.conversationId).notifier)
          .sendMessage(content);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        // Restore the text so user doesn't lose their message
        _controller.text = content;
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    // Scroll to bottom when new messages load
    messagesAsync.whenData((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.participantAvatar != null
                  ? NetworkImage(widget.participantAvatar!)
                  : null,
              child: widget.participantAvatar == null
                  ? Text(
                      widget.participantName.isNotEmpty
                          ? widget.participantName[0].toUpperCase()
                          : '?',
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.participantName),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Messages list ──────────────────────────────────────────────────
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildError(e.toString()),
              data: (messages) => messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessagesList(messages),
            ),
          ),

          // ── Composer ───────────────────────────────────────────────────────
          _buildComposer(),
        ],
      ),
    );
  }

  // ─── Message List ─────────────────────────────────────────────────────────

  Widget _buildMessagesList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
        vertical: AppDimensions.spaceSmall,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe =
            message.senderId != null && message.senderId == _currentUserId(ref);
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white.withOpacity(0.65)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Composer ─────────────────────────────────────────────────────────────

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.spaceMedium,
        right: AppDimensions.spaceMedium,
        top: AppDimensions.spaceSmall,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? AppDimensions.spaceSmall
            : AppDimensions.spaceMedium,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: 5,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Write a message...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSending
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 44,
                      height: 44,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : GestureDetector(
                      key: const ValueKey('send'),
                      onTap: _controller.text.trim().isEmpty
                          ? null
                          : _sendMessage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _controller.text.trim().isEmpty
                              ? AppColors.divider
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty / Error states ─────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No messages yet.\nSay hello!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  // Pull the current user id from your auth provider
  String? _currentUserId(WidgetRef ref) {
    // TODO: swap with your actual auth provider, e.g.:
    return ref.read(authProvider).user?.id;
  }
}
