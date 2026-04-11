import 'package:dio/dio.dart';
import 'package:my_project/models/user.dart';

class NotificationsService {
  final Dio _dio;
  String baseUrl = 'http://68.210.102.76/api';
  NotificationsService({required Dio dio})
    : _dio = dio; //must set private like this

  // Endpoint #1 (Module 10) — GET /notifications
  Future<List<User>> getNotifications() async {
    final response = await _dio.get('$baseUrl/notifications');
    return response.data as List<User>;
  }

  // Endpoint #2 (Module 10) — PUT /notifications/{id}/read
  Future<void> markNotificationAsRead({required int id}) async {
    await _dio.put('$baseUrl/notifications/$id/read');
  }
}
