class Participant {
  final String? userId;
  final String displayName;
  final String? profilePicture;

  Participant({
    required this.userId,
    required this.displayName,
    this.profilePicture,
  });

  // models/conversation.dart — Participant part
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'] as String?, // ← snake_case
      displayName: json['display_name'] as String? ?? 'Unknown',
      profilePicture: json['profile_picture'] as String?,
    );
  }
}

class Conversation {
  final String conversationId;
  final String createdAt;
  final List<Participant> participants;

  Conversation({
    required this.conversationId,
    required this.createdAt,
    required this.participants,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversation_id'],
      createdAt: json['created_at'],
      participants: (json['participants'] as List)
          .map((e) => Participant.fromJson(e))
          .toList(),
    );
  }
}
