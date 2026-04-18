class Track {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userProfilePicture;
  final String title;
  final String description;
  final String? genre;
  final List<String> tags;
  final String? artworkUrl;
  final String fileUrl;

  // ─── Backward compatibility getters ────────────────────────────────────────

  /// Alias for [userDisplayName] — replaces the old flat `artist` field.
  String get artist => userDisplayName;

  /// Alias for [fileUrl] — replaces the old `audioPath` field.
  String get audioPath => fileUrl;

  /// Safe non-nullable getter for [artworkUrl] — falls back to empty string.
  String get artworkUrlSafe => artworkUrl ?? '';

  /// Safe non-nullable getter for [genre] — falls back to empty string.
  String get genreSafe => genre ?? '';

  /// Safe non-nullable getter for [userProfilePicture] — falls back to empty string.
  String get profilePictureSafe => userProfilePicture ?? '';

  /// Safe non-nullable getter for [releaseDate] — falls back to empty string.
  String get releaseDateSafe => releaseDate ?? '';

  final String visibility;
  final int duration;
  final int playCount;
  final int likeCount;
  final int repostCount;
  final int commentCount;
  final bool isLiked;
  final bool isReposted;
  final String? releaseDate;
  final String createdAt;

  Track({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userProfilePicture,
    required this.title,
    required this.description,
    this.genre,
    this.tags = const [],
    this.artworkUrl,
    required this.fileUrl,
    required this.visibility,
    required this.duration,
    required this.playCount,
    required this.likeCount,
    required this.repostCount,
    required this.commentCount,
    required this.isLiked,
    required this.isReposted,
    this.releaseDate,
    required this.createdAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userDisplayName: json['display_name'] ?? '',
      userProfilePicture: json['profile_picture'] as String?,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      genre: json['genre'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      artworkUrl: json['artwork_url'] as String?,
      fileUrl: json['file_url'] ?? '',
      visibility: json['visibility'] ?? 'public',
      duration: json['duration'] ?? 0,
      playCount: json['play_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      repostCount: json['repost_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isReposted: json['is_reposted'] ?? false,
      releaseDate: json['release_date'] as String?,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': userDisplayName,
      'profile_picture': userProfilePicture,
      'title': title,
      'description': description,
      'genre': genre,
      'tags': tags,
      'artwork_url': artworkUrl,
      'file_url': fileUrl,
      'visibility': visibility,
      'duration': duration,
      'play_count': playCount,
      'like_count': likeCount,
      'repost_count': repostCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'is_reposted': isReposted,
      'release_date': releaseDate,
      'created_at': createdAt,
    };
  }

  Track copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? userProfilePicture,
    String? title,
    String? description,
    String? genre,
    List<String>? tags,
    String? artworkUrl,
    String? fileUrl,
    String? visibility,
    int? duration,
    int? playCount,
    int? likeCount,
    int? repostCount,
    int? commentCount,
    bool? isLiked,
    bool? isReposted,
    String? releaseDate,
    String? createdAt,
  }) {
    return Track(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      title: title ?? this.title,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      tags: tags ?? this.tags,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      visibility: visibility ?? this.visibility,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      repostCount: repostCount ?? this.repostCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      releaseDate: releaseDate ?? this.releaseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
