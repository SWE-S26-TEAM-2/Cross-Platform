// models/feed.dart

class FeedResponse {
  final bool success;
  final double? queryTimeMs;
  final FeedData data;

  FeedResponse({required this.success, this.queryTimeMs, required this.data});

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      success: json['success'] as bool,
      queryTimeMs: json['query_time_ms'] != null
          ? (json['query_time_ms'] as num).toDouble()
          : null,
      data: FeedData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class FeedData {
  final List<FeedTrackItem> items;
  final String? nextCursor;
  final bool hasMore;

  FeedData({required this.items, this.nextCursor, required this.hasMore});

  factory FeedData.fromJson(Map<String, dynamic> json) {
    return FeedData(
      items: (json['items'] as List)
          .map((e) => FeedTrackItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }
}

class FeedTrackItem {
  final String trackId;
  final String title;
  final String? description;
  final String? genre;
  final List<dynamic>? tags;
  final String? releaseDate;
  final String? coverImageUrl;
  final String streamUrl;
  final int? durationSeconds;
  final int playCount;
  final int likeCount;
  final int repostCount;
  final int commentCount;
  final bool isLiked;
  final bool isReposted;
  final DateTime? createdAt;
  final FeedArtist artist;

  FeedTrackItem({
    required this.trackId,
    required this.title,
    this.description,
    this.genre,
    this.tags,
    this.releaseDate,
    this.coverImageUrl,
    required this.streamUrl,
    this.durationSeconds,
    required this.playCount,
    required this.likeCount,
    required this.repostCount,
    required this.commentCount,
    required this.isLiked,
    required this.isReposted,
    this.createdAt,
    required this.artist,
  });

  factory FeedTrackItem.fromJson(Map<String, dynamic> json) {
    return FeedTrackItem(
      trackId: json['track_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      genre: json['genre'] as String?,
      tags: json['tags'] as List<dynamic>?,
      releaseDate: json['release_date'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      streamUrl: json['stream_url'] as String,
      durationSeconds: json['duration_seconds'] as int?,
      playCount: json['play_count'] as int,
      likeCount: json['like_count'] as int,
      repostCount: json['repost_count'] as int,
      commentCount: json['comment_count'] as int,
      isLiked: json['is_liked'] as bool,
      isReposted: json['is_reposted'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      artist: FeedArtist.fromJson(json['artist'] as Map<String, dynamic>),
    );
  }
}

class FeedArtist {
  final String userId;
  final String username;
  final String displayName;
  final String? profilePicture;
  final int followerCount;

  FeedArtist({
    required this.userId,
    required this.username,
    required this.displayName,
    this.profilePicture,
    required this.followerCount,
  });

  factory FeedArtist.fromJson(Map<String, dynamic> json) {
    return FeedArtist(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      followerCount: json['follower_count'] as int,
    );
  }
}

class CachedFeedResponse {
  final bool success;
  final bool optimized;
  final bool cacheHit;
  final double queryTimeMs;
  final String? cachedAt;
  final int cacheTtlSeconds;
  final FeedData data;

  CachedFeedResponse({
    required this.success,
    required this.optimized,
    required this.cacheHit,
    required this.queryTimeMs,
    this.cachedAt,
    required this.cacheTtlSeconds,
    required this.data,
  });

  factory CachedFeedResponse.fromJson(Map<String, dynamic> json) {
    return CachedFeedResponse(
      success: json['success'] as bool,
      optimized: json['optimized'] as bool,
      cacheHit: json['cache_hit'] as bool,
      queryTimeMs: (json['query_time_ms'] as num).toDouble(),
      cachedAt: json['cached_at'] as String?,
      cacheTtlSeconds: json['cache_ttl_seconds'] as int,
      data: FeedData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
