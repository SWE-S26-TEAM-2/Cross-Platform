import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ─── Service Provider ─────────────────────────────────────────────────────────

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(dio: Dio());
});

// ─── Notifications Notifier ───────────────────────────────────────────────────

class NotificationsNotifier extends AsyncNotifier<List<Notification>> {
  @override
  Future<List<Notification>> build() async {
    try {
      return await ref.read(notificationsServiceProvider).getNotifications();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _mockNotifications;
      }
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return;

    await ref
        .read(notificationsServiceProvider)
        .markNotificationAsRead(id: intId);

    // update locally so the blue dot disappears instantly
    state = AsyncData(
      state.value?.map((n) {
            return n.id == id
                ? Notification(
                    id: n.id,
                    type: n.type,
                    message: n.message,
                    isRead: true, // flip to true
                    createdAt: n.createdAt,
                  )
                : n;
          }).toList() ??
          [],
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationsServiceProvider).getNotifications(),
    );
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<Notification>>(
      NotificationsNotifier.new,
    );
