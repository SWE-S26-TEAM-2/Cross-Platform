import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications_service.dart';

// Service provider
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(dio: Dio());
});

// Get all notifications provider
final getNotificationsProvider = FutureProvider<void>((ref) async {
  final notificationsService = ref.watch(notificationsServiceProvider);
  return await notificationsService.getNotifications();
});

// Mark notification as read provider
final markNotificationAsReadProvider = FutureProvider.family<void, int>((
  ref,
  id,
) async {
  final notificationsService = ref.watch(notificationsServiceProvider);
  return await notificationsService.markNotificationAsRead(id: id);
});
