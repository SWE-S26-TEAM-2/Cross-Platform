// models/track.dart

class TrackArtist {
  final String userId;
  final String username;
  final String displayName;
  final String? profilePicture;
  final int followerCount;

  const TrackArtist({
    required this.userId,
    required this.username,
    required this.displayName,
    this.profilePicture,
    required this.followerCount,
  });

  factory TrackArtist.fromJson(Map<String, dynamic> json) {
    return TrackArtist(
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString(),
      followerCount: json['follower_count'] as int? ?? 0,
    );
  }
}

class Track {
  final String trackId;
  final String title;
  final String? description;
  final String? genre;
  final List<dynamic>? tags;
  final String? releaseDate;
  final String? coverImageUrl;
  final String streamUrl;
  final String? userId; // present in TrackData (own tracks / search)
  final TrackArtist? artist; // present in FeedTrackItem
  final String visibility;
  final String processingStatus;
  final int playCount;
  final int? durationSeconds;
  // Feed / engagement fields (nullable — not in every response)
  final int? likeCount;
  final int? repostCount;
  final int? commentCount;
  final bool? isLiked;
  final bool? isReposted;
  final DateTime? createdAt;

  const Track({
    required this.trackId,
    required this.title,
    this.description,
    this.genre,
    this.tags,
    this.releaseDate,
    this.coverImageUrl,
    required this.streamUrl,
    this.userId,
    this.artist,
    required this.visibility,
    required this.processingStatus,
    required this.playCount,
    this.durationSeconds,
    this.likeCount,
    this.repostCount,
    this.commentCount,
    this.isLiked,
    this.isReposted,
    this.createdAt,
  });

  /// Works for both TrackData (GET /tracks/{id}) and FeedTrackItem.
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      trackId: json['track_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      genre: json['genre']?.toString(),
      tags: json['tags'] as List<dynamic>?,
      releaseDate: json['release_date']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      streamUrl: json['stream_url']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      artist: json['artist'] != null
          ? TrackArtist.fromJson(json['artist'] as Map<String, dynamic>)
          : null,
      visibility: json['visibility']?.toString() ?? 'public',
      processingStatus: json['processing_status']?.toString() ?? '',
      playCount: json['play_count'] as int? ?? 0,
      durationSeconds: json['duration_seconds'] as int?,
      likeCount: json['like_count'] as int?,
      repostCount: json['repost_count'] as int?,
      commentCount: json['comment_count'] as int?,
      isLiked: json['is_liked'] as bool?,
      isReposted: json['is_reposted'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Alias for coverImageUrl to maintain compatibility with code expecting 'artworkUrl'
  String? get artworkUrl => coverImageUrl;

  /// Gets the artist's display name or empty string if null
  String get artistName => artist?.displayName ?? '';

  /// Gets formatted artist name with fallback
  String get formattedArtist => artist?.displayName ?? 'Unknown Artist';

  /// Convenience copy-with for local optimistic updates (e.g. toggling like).
  Track copyWith({
    int? likeCount,
    bool? isLiked,
    int? repostCount,
    bool? isReposted,
    int? commentCount,
    String? coverImageUrl,
  }) {
    return Track(
      trackId: trackId,
      title: title,
      description: description,
      genre: genre,
      tags: tags,
      releaseDate: releaseDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      streamUrl: streamUrl,
      userId: userId,
      artist: artist,
      visibility: visibility,
      processingStatus: processingStatus,
      playCount: playCount,
      durationSeconds: durationSeconds,
      likeCount: likeCount ?? this.likeCount,
      repostCount: repostCount ?? this.repostCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      createdAt: createdAt,
    );
  }
}
