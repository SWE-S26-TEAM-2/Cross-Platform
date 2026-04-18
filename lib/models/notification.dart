// models/notification.dart
class Notification {
  final String id;
  final String type;
  final String message;
  final bool isRead;
  final String? createdAt;

  Notification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'].toString(), // API returns "notif-1" etc.
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false, // ← snake_case
      createdAt: json['created_at'] as String?, // ← snake_case
    );
  }
}
