class Album {
  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final int trackCount;
  final int releaseYear;
  final int likeCount;
  final List<String> trackIds;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.trackCount,
    required this.releaseYear,
    required this.likeCount,
    this.trackIds = const [],
  });

  static String _fixMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return 'https://streamline-swp.duckdns.org$url';
    return url;
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    // release_date may be a full date string "2024-01-15" or null
    int releaseYear = 0;
    final rawDate = json['release_date']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      releaseYear = int.tryParse(rawDate.split('-').first) ?? 0;
    }

    return Album(
      id: json['album_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Album',
      // The API returns the uploader's info nested or flat — fall back chain
      artist: json['artist']?.toString() ??
          json['display_name']?.toString() ??
          json['owner']?.toString() ??
          'Unknown Artist',
      artworkUrl: _fixMediaUrl(
        json['cover_photo_url']?.toString() ??
            json['cover_image_url']?.toString() ??
            json['artwork_url']?.toString(),
      ),
      trackCount: json['track_count'] is int
          ? json['track_count']
          : int.tryParse(json['track_count']?.toString() ?? '') ?? 0,
      releaseYear: releaseYear,
      likeCount: json['like_count'] is int
          ? json['like_count']
          : int.tryParse(json['like_count']?.toString() ?? '') ?? 0,
      trackIds: (json['track_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}