import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/mock_data/mock_users.dart';
import '../services/notifications_service.dart';
import '../models/notification.dart';

// Mock data to use as fallback
final _mockNotifications = [
  Notification(
    id: '1',
    type: 'like',
    message: 'Someone liked your track.',
    isRead: false,
    createdAt: '2025-04-01T10:00:00Z',
  ),
  Notification(
    id: '2',
    type: 'follow',
    message: 'Someone followed you.',
    isRead: false,
    createdAt: '2025-04-01T09:00:00Z',
  ),
];

// Service provider
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(dio: Dio());
});

// Get all notifications provider
final getNotificationsProvider = FutureProvider<List<Notification>>((
  ref,
) async {
  final notificationsService = ref.watch(notificationsServiceProvider);
  try {
    return await notificationsService.getNotifications();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      return _mockNotifications;
    }
    rethrow;
  }
});

// Mark notification as read provider
final markNotificationAsReadProvider = FutureProvider.family<void, int>((
  ref,
  id,
) async {
  final notificationsService = ref.watch(notificationsServiceProvider);
  return await notificationsService.markNotificationAsRead(id: id);
});
