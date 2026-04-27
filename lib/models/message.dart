class Message {
  final String id;
  final String? senderId; // ← nullable, some contexts might omit it
  final String? receiverId;
  final String content;
  final bool isRead;
  final String? createdAt;

  final String? trackId;
  final String? playlistId;

  Message({
    required this.id,
    this.senderId,
    this.receiverId,
    required this.content,
    required this.isRead,
    this.createdAt,
    this.trackId,
    this.playlistId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String?, // ← snake_case
      receiverId: json['receiver_id'] as String?, // ← snake_case
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String?, // ← snake_case
      trackId: json['track_id'] as String?,
      playlistId: json['playlist_id'] as String?,
    );
  }
}
