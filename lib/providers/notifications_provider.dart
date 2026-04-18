import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications_service.dart';
import '../models/notification.dart';
import 'auth_providers.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
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
  return NotificationsService(dio: dio);
});

// ─── Unread Count Provider ────────────────────────────────────────────────────

final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  try {
    return await ref.read(notificationsServiceProvider).getUnreadCount();
  } catch (_) {
    return 0;
  }
});

// ─── Notifications Notifier ───────────────────────────────────────────────────

class NotificationsNotifier extends AsyncNotifier<List<Notification>> {
  @override
  Future<List<Notification>> build() async {
    try {
      return await ref.read(notificationsServiceProvider).getNotifications();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      throw Exception('Could not load notifications. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Mark single notification as read
  Future<void> markAsRead(String id) async {
    await ref.read(notificationsServiceProvider).markNotificationAsRead(id: id);

    // Update locally so blue dot disappears instantly
    state = AsyncData(
      state.value?.map((n) {
            return n.id == id
                ? Notification(
                    id: n.id,
                    type: n.type,
                    message: n.message,
                    isRead: true,
                    createdAt: n.createdAt,
                  )
                : n;
          }).toList() ??
          [],
    );
    ref.invalidate(unreadNotificationsCountProvider);
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await ref.read(notificationsServiceProvider).markAllAsRead();

    // Update all locally
    state = AsyncData(
      state.value
              ?.map(
                (n) => Notification(
                  id: n.id,
                  type: n.type,
                  message: n.message,
                  isRead: true,
                  createdAt: n.createdAt,
                ),
              )
              .toList() ??
          [],
    );
    ref.invalidate(unreadNotificationsCountProvider);
  }

  // Delete a single notification
  Future<void> deleteNotification(String id) async {
    await ref.read(notificationsServiceProvider).deleteNotification(id: id);

    // Remove locally immediately
    state = AsyncData(state.value?.where((n) => n.id != id).toList() ?? []);
    ref.invalidate(unreadNotificationsCountProvider);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationsServiceProvider).getNotifications(),
    );
    ref.invalidate(unreadNotificationsCountProvider);
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<Notification>>(
      NotificationsNotifier.new,
    );
