class Message {
  final String messageId;
  final String senderId;
  final String content;
  final bool isRead;
  final String createdAt;

  Message({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      senderId: json['sender_id'],
      content: json['content'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
    );
  }
}
