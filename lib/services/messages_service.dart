import 'package:dio/dio.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class MessagesService {
  final Dio _dio;
  String baseUrl = 'http://68.210.102.76/api';
  MessagesService({required Dio dio}) : _dio = dio; //must set private like this

  // POST /conversations — create or retrieve a conversation
  Future<String> createOrGetConversation({
    required String participantId,
  }) async {
    final response = await _dio.post(
      '$baseUrl/conversations',
      data: {'participant_id': participantId},
    );
    return response.data['data']['conversation_id'];
  }

  // GET /conversations — list all conversations
  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get('$baseUrl/conversations');
    final List data = response.data['data'];
    return data.map((e) => Conversation.fromJson(e)).toList();
  }

  // DELETE /conversations/{conversation_id}
  Future<void> deleteConversation({required String conversationId}) async {
    await _dio.delete('$baseUrl/conversations/$conversationId');
  }

  // GET /conversations/{conversation_id}/messages
  Future<List<Message>> getMessages({required String conversationId}) async {
    final response = await _dio.get(
      '$baseUrl/conversations/$conversationId/messages',
    );
    final List data = response.data['data'];
    return data.map((e) => Message.fromJson(e)).toList();
  }

  // POST /conversations/{conversation_id}/messages
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    await _dio.post(
      '$baseUrl/conversations/$conversationId/messages',
      data: {'content': content},
    );
  }

  // PATCH /conversations/{conversation_id}/messages/{message_id}/read
  Future<void> markMessageAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    await _dio.patch(
      '$baseUrl/conversations/$conversationId/messages/$messageId/read',
    );
  }
}
