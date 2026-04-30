// models/follower.dart

class Follower {
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool? isFollowing;
  final bool? isPremium;
  final String? followedAt;

  const Follower({
    required this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.isFollowing,
    this.isPremium,
    this.followedAt,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      userId: json['user_id']?.toString() ?? '',
      username: (json['username'] ?? json['user_name'])?.toString(),
      displayName: json['display_name']?.toString(),
      avatarUrl:
          json['profile_picture']?.toString() ?? json['avatar_url']?.toString(),
      bio: json['bio']?.toString(),
      isFollowing: json['is_following'] as bool?,
      isPremium: json['is_premium'] as bool?,
      followedAt: json['followed_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    if (username != null) 'username': username,
    if (displayName != null) 'display_name': displayName,
    if (avatarUrl != null) 'profile_picture': avatarUrl,
    if (bio != null) 'bio': bio,
    if (isFollowing != null) 'is_following': isFollowing,
    if (isPremium != null) 'is_premium': isPremium,
    if (followedAt != null) 'followed_at': followedAt,
  };

  Follower copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    bool? isFollowing,
    bool? isPremium,
    String? followedAt,
  }) {
    return Follower(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isFollowing: isFollowing ?? this.isFollowing,
      isPremium: isPremium ?? this.isPremium,
      followedAt: followedAt ?? this.followedAt,
    );
  }

  /// The identifier to use in API path params like /users/{username}/follow.
  /// Falls back to userId because the following-list response omits username.
  String get apiIdentifier =>
      (username != null && username!.isNotEmpty) ? username! : userId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Follower &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

// ─── FollowerListResponse ─────────────────────────────────────────────────────

class FollowerListResponse {
  final List<Follower> followers;
  final int? count;

  const FollowerListResponse({required this.followers, this.count});

  factory FollowerListResponse.fromJson(Map<String, dynamic> json) {
    final List raw = (json['followers'] ?? json['items'] ?? []) as List? ?? [];
    return FollowerListResponse(
      followers: raw
          .map((e) => Follower.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );
  }
}

// ─── FollowingListResponse ────────────────────────────────────────────────────

class FollowingListResponse {
  final List<Follower> following;
  final int? count;

  const FollowingListResponse({required this.following, this.count});

  factory FollowingListResponse.fromJson(Map<String, dynamic> json) {
    final List raw = (json['following'] ?? json['items'] ?? []) as List? ?? [];
    return FollowingListResponse(
      following: raw
          .map((e) => Follower.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );
  }
}
