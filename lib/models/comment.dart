class Comment {
  final String id;
  final String trackId;
  final String userId;
  final String userDisplayName;
  final String? userProfilePicture;
  final String content;
  final int? timestampInTrack;
  final String? parentCommentId;
  final List<Comment> replies;
  final String createdAt;

  Comment({
    required this.id,
    required this.trackId,
    required this.userId,
    required this.userDisplayName,
    this.userProfilePicture,
    required this.content,
    this.timestampInTrack,
    this.parentCommentId,
    this.replies = const [],
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      trackId: json['track_id'] as String,
      userId: json['user_id'] as String,
      userDisplayName: json['display_name'] as String,
      userProfilePicture: json['profile_picture'] as String?,
      content: json['content'] as String,
      timestampInTrack: json['timestamp_in_track'] as int?,
      parentCommentId: json['parent_comment_id'] as String?,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'track_id': trackId,
      'user_id': userId,
      'display_name': userDisplayName,
      'profile_picture': userProfilePicture,
      'content': content,
      'timestamp_in_track': timestampInTrack,
      'parent_comment_id': parentCommentId,
      'replies': replies.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
    };
  }
}
