import 'package:dio/dio.dart';
import '../models/notification.dart';

class NotificationsService {
  final Dio _dio;
  static const String _baseUrl = 'https://streamline-swp.duckdns.org/api';

  NotificationsService({required Dio dio}) : _dio = dio;

  // GET /notifications
  Future<List<Notification>> getNotifications() async {
    final response = await _dio.get('$_baseUrl/notifications');
    final raw = response.data['data'];
    final List data;
    if (raw is List) {
      data = raw;
    } else if (raw is Map) {
      data =
          (raw['notifications'] ?? raw['items'] ?? raw['results'] ?? [])
              as List;
    } else {
      data = [];
    }
    return data.map((e) => Notification.fromJson(e)).toList();
  }

  // GET /notifications/unread-count
  Future<int> getUnreadCount() async {
    final response = await _dio.get('$_baseUrl/notifications/unread-count');
    return response.data['data']['unread_count'] as int? ?? 0;
  }

  // PUT /notifications/read-all
  Future<void> markAllAsRead() async {
    await _dio.put('$_baseUrl/notifications/read-all');
  }

  // PUT /notifications/{notification_id}/read
  Future<void> markNotificationAsRead({required String id}) async {
    await _dio.put('$_baseUrl/notifications/$id/read');
  }

  // DELETE /notifications/{notification_id}
  Future<void> deleteNotification({required String id}) async {
    await _dio.delete('$_baseUrl/notifications/$id');
  }
}
