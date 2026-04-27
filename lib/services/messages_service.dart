import 'package:dio/dio.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class MessagesService {
  final Dio _dio;
  static const String _baseUrl = 'https://streamline-swp.duckdns.org/api';

  MessagesService({required Dio dio}) : _dio = dio;

  // POST /conversations
  // API requires: display_name (NOT participant_id — check CreateConversationRequest in spec)
  Future<String> createOrGetConversation({
    required String participantId,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/conversations',
      data: {'participant_id': participantId},
    );
    return response.data['data']['conversation_id'];
  }

  // GET /conversations
  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get('$_baseUrl/conversations');
    final List data = response.data['data'] ?? [];
    return data.map((e) => Conversation.fromJson(e)).toList();
  }

  // DELETE /conversations/{conversation_id}
  Future<void> deleteConversation({required String conversationId}) async {
    await _dio.delete('$_baseUrl/conversations/$conversationId');
  }

  // GET /conversations/{conversation_id}/messages
  Future<List<Message>> getMessages({required String conversationId}) async {
    final response = await _dio.get(
      '$_baseUrl/conversations/$conversationId/messages',
    );
    final List data = response.data['data'] ?? [];
    return data.map((e) => Message.fromJson(e)).toList();
  }

  // POST /conversations/{conversation_id}/messages
  // content, track_id, playlist_id are all optional but at least one must be provided
  Future<void> sendMessage({
    required String conversationId,
    String? content,
    String? trackId,
    String? playlistId,
  }) async {
    await _dio.post(
      '$_baseUrl/conversations/$conversationId/messages',
      data: {
        if (content != null) 'content': content,
        if (trackId != null) 'track_id': trackId,
        if (playlistId != null) 'playlist_id': playlistId,
      },
    );
  }

  // PATCH /conversations/{conversation_id}/messages/{message_id}/read
  Future<void> markMessageAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    await _dio.patch(
      '$_baseUrl/conversations/$conversationId/messages/$messageId/read',
    );
  }

  // PATCH /conversations/{conversation_id}/messages/read-all
  Future<void> markAllMessagesAsRead({required String conversationId}) async {
    await _dio.patch(
      '$_baseUrl/conversations/$conversationId/messages/read-all',
    );
  }

  // GET /conversations/unread-count
  Future<int> getUnreadCount() async {
    final response = await _dio.get('$_baseUrl/conversations/unread-count');
    return response.data['data']['unread_count'] as int? ?? 0;
  }
}
