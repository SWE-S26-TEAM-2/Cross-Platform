class PlaylistTrack {
  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final int durationSeconds;

  const PlaylistTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.durationSeconds,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    String fixMediaUrl(String? url) {
      if (url == null || url.isEmpty) return '';

      if (url.startsWith('http')) return url;

      if (url.startsWith('/')) {
        return 'https://streamline-swp.duckdns.org$url';
      }

      return url;
    }

    return PlaylistTrack(
      id: json['track_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Track',
      artist:
          json['artist_name']?.toString() ??
          json['artist']?.toString() ??
          'Unknown Artist',
      artworkUrl: fixMediaUrl(
        json['cover_image_url']?.toString() ??
            json['cover_url']?.toString() ??
            json['artwork_url']?.toString(),
      ),
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds']
          : int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
    );
  }
}

class Playlist {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String coverUrl;
  final bool isPublic;
  final int trackCount;
  final List<PlaylistTrack> tracks;

  const Playlist({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.isPublic,
    required this.trackCount,
    required this.tracks,
  });

  String get owner => 'Playlist owner';

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final tracksRaw = json['tracks'];

    final tracks = tracksRaw is List
        ? tracksRaw
              .whereType<Map<String, dynamic>>()
              .map(PlaylistTrack.fromJson)
              .toList()
        : <PlaylistTrack>[];

    String fixMediaUrl(String? url) {
      if (url == null || url.isEmpty) return '';

      if (url.startsWith('http')) return url;

      if (url.startsWith('/')) {
        return 'https://streamline-swp.duckdns.org$url';
      }

      return url;
    }

    final rawCoverUrl =
        json['cover_photo_url']?.toString() ??
        json['cover_url']?.toString() ??
        '';
    print('FINAL PARSED PLAYLIST COVER: ${fixMediaUrl(rawCoverUrl)}');
    return Playlist(
      id: json['playlist_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled playlist',
      description: json['description']?.toString() ?? '',
      coverUrl: fixMediaUrl(rawCoverUrl),
      isPublic: json['is_public'] == true,
      trackCount: json['track_count'] is int
          ? json['track_count']
          : tracks.length,
      tracks: tracks,
    );
  }
}
