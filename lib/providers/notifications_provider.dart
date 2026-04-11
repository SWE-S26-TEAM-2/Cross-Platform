import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/mock_data/mock_users.dart';
import '../services/notifications_service.dart';

// Mock data to use as fallback
final _mockNotifications = mockUsers;

// Service provider
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(dio: Dio());
});

// Get all notifications provider
final getNotificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final notificationsService = ref.watch(notificationsServiceProvider);
  try {
    return await notificationsService.getNotifications();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      return _mockNotifications; // fallback to mock data
    }
    rethrow; // any other error still shows as error in the UI
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
