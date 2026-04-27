class Playlist {
  final String id;
  final String name;
  final String owner;
  final String? coverUrl;
  final int trackCount;
  final String? duration;

  const Playlist({
    required this.id,
    required this.name,
    required this.owner,
    required this.coverUrl,
    required this.trackCount,
    required this.duration,
  });
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id']?.toString() ?? json['playlist_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      owner:
          json['display_name']?.toString() ?? json['owner']?.toString() ?? '',
      coverUrl: json['cover_photo_url']?.toString() ?? '',
      trackCount: json['track_count'] as int? ?? 0,
      duration: json['duration']?.toString() ?? '',
    );
  }
}
