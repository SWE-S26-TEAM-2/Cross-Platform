import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/notification.dart';

class NotificationsService {
  final Dio _dio;
  String baseUrl = apiBaseUrl;
  NotificationsService({required Dio dio})
    : _dio = dio; //must set private like this

  // Endpoint #1 (Module 10) — GET /notifications
  Future<List<Notification>> getNotifications() async {
    final response = await _dio.get('$baseUrl/notifications');

    final raw = response.data['data'];

    // API should return a List, but guard against a Map wrapper
    final List data;
    if (raw is List) {
      data = raw;
    } else if (raw is Map) {
      // e.g. { "notifications": [...], "unread_count": 5 }
      // try common nested keys
      data =
          (raw['notifications'] ?? raw['items'] ?? raw['results'] ?? [])
              as List;
    } else {
      data = [];
    }

    return data.map((e) => Notification.fromJson(e)).toList();
  }

  // Endpoint #2 (Module 10) — PUT /notifications/{id}/read
  Future<void> markNotificationAsRead({required int id}) async {
    await _dio.put('$baseUrl/notifications/$id/read');
  }
}
