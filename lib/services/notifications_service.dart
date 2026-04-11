import 'package:dio/dio.dart';
import 'package:my_project/models/user.dart';
import '../models/notification.dart';

class NotificationsService {
  final Dio _dio;
  String baseUrl = 'http://68.210.102.76/api';
  NotificationsService({required Dio dio})
    : _dio = dio; //must set private like this

  // Endpoint #1 (Module 10) — GET /notifications
  Future<List<Notification>> getNotifications() async {
    final response = await _dio.get('$baseUrl/notifications');
    final List data = response.data['data'];
    return data.map((e) => Notification.fromJson(e)).toList();
  }

  // Endpoint #2 (Module 10) — PUT /notifications/{id}/read
  Future<void> markNotificationAsRead({required int id}) async {
    await _dio.put('$baseUrl/notifications/$id/read');
  }
}
