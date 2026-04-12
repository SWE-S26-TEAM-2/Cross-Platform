import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/conversation.dart';
import 'package:my_project/models/message.dart';
import 'package:my_project/services/messages_service.dart';
import 'auth_providers.dart';

// ─── Service Provider ────────────────────────────────────────────────────────

final messagingServiceProvider = Provider<MessagesService>((ref) {
  final token = ref.watch(authProvider).tokens?.accessToken ?? '';
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  );

  return MessagesService(dio: dio);
});

// ─── GET /conversations ───────────────────────────────────────────────────────

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    try {
      return await ref.read(messagingServiceProvider).getConversations();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        return []; // no conversations yet
      }
      throw Exception('Could not load messages. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
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
    ref.invalidateSelf();
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
    try {
      return await ref
          .read(messagingServiceProvider)
          .getMessages(conversationId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You are not a participant in this conversation.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Conversation not found.');
      }
      throw Exception('Could not load messages. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    await ref
        .read(messagingServiceProvider)
        .sendMessage(conversationId: arg, content: content);
    ref.invalidateSelf();
  }

  Future<void> markAsRead(String messageId) async {
    await ref
        .read(messagingServiceProvider)
        .markMessageAsRead(conversationId: arg, messageId: messageId);
    ref.invalidateSelf();
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
    try {
      return await ref
          .read(messagingServiceProvider)
          .createOrGetConversation(participantId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Cannot start a conversation with yourself.');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      throw Exception('Could not start conversation. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final createConversationProvider =
    AsyncNotifierProviderFamily<CreateConversationNotifier, String, String>(
      CreateConversationNotifier.new,
    );
