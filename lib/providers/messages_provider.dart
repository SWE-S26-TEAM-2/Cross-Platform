import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/conversation.dart';
import 'package:my_project/models/message.dart';
import 'package:my_project/services/messages_service.dart';

// ─── Service Provider ────────────────────────────────────────────────────────

final messagingServiceProvider = Provider<MessagesService>((ref) {
  return MessagesService(dio: Dio());
});

// ─── GET /conversations ───────────────────────────────────────────────────────

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    return await ref.watch(messagingServiceProvider).getConversations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(messagingServiceProvider).getConversations(),
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    await ref
        .read(messagingServiceProvider)
        .deleteConversation(conversationId: conversationId);
    ref.invalidateSelf(); // re-fetch conversations after deleting
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
      ConversationsNotifier.new,
    );

// ─── GET /conversations/{id}/messages ────────────────────────────────────────

class MessagesNotifier extends FamilyAsyncNotifier<List<Message>, String> {
  @override
  Future<List<Message>> build(String arg) async {
    return await ref
        .watch(messagingServiceProvider)
        .getMessages(conversationId: arg);
  }

  Future<void> sendMessage(String content) async {
    await ref
        .read(messagingServiceProvider)
        .sendMessage(conversationId: arg, content: content);
    ref.invalidateSelf(); // re-fetch messages after sending
  }

  Future<void> markAsRead(String messageId) async {
    await ref
        .read(messagingServiceProvider)
        .markMessageAsRead(conversationId: arg, messageId: messageId);
    ref.invalidateSelf(); // re-fetch to update read status
  }
}

final messagesProvider =
    AsyncNotifierProviderFamily<MessagesNotifier, List<Message>, String>(
      MessagesNotifier.new,
    );

// ─── POST /conversations ──────────────────────────────────────────────────────

class CreateConversationNotifier extends FamilyAsyncNotifier<String, String> {
  @override
  Future<String> build(String arg) async {
    return await ref
        .watch(messagingServiceProvider)
        .createOrGetConversation(participantId: arg);
  }
}

final createConversationProvider =
    AsyncNotifierProviderFamily<CreateConversationNotifier, String, String>(
      CreateConversationNotifier.new,
    );
