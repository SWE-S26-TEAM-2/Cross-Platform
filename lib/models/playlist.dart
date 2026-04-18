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
    String artistName = '';

    if (json['artist_name'] != null) {
      artistName = json['artist_name'].toString();
    } else if (json['artist'] is Map<String, dynamic>) {
      final artistMap = json['artist'] as Map<String, dynamic>;
      artistName =
          artistMap['display_name']?.toString() ??
          artistMap['username']?.toString() ??
          '';
    } else if (json['artist'] != null) {
      artistName = json['artist'].toString();
    }

    final rawArtwork =
        json['artwork_url']?.toString() ??
        json['cover_url']?.toString() ??
        json['image_url']?.toString() ??
        '';

    return PlaylistTrack(
      id:
          json['track_id']?.toString() ??
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title:
          json['title']?.toString() ??
          json['name']?.toString() ??
          'Untitled Track',
      artist: artistName.isEmpty ? 'Unknown Artist' : artistName,
      artworkUrl: rawArtwork,
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds']
          : int.tryParse(json['duration_seconds']?.toString() ?? '') ??
                (json['duration'] is int ? json['duration'] : 0),
    );
  }
}

class Playlist {
  final String id;
  final String name;
  final String owner;
  final String coverUrl;
  final int trackCount;
  final String duration;
  final String? description;
  final bool isPublic;
  final String? userId;
  final List<PlaylistTrack> tracks;

  const Playlist({
    required this.id,
    required this.name,
    required this.owner,
    required this.coverUrl,
    required this.trackCount,
    required this.duration,
    this.description,
    required this.isPublic,
    this.userId,
    required this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final tracksJson = (json['tracks'] as List?) ?? [];
    final tracks = tracksJson
        .whereType<Map<String, dynamic>>()
        .map(PlaylistTrack.fromJson)
        .toList();

    final int totalDurationSeconds = tracks.fold(
      0,
      (sum, track) => sum + track.durationSeconds,
    );

    String formatDuration(int seconds) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final secs = seconds % 60;

      if (hours > 0) {
        return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
      }
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }

    final cover =
        json['cover_url']?.toString() ??
        (tracks.isNotEmpty ? tracks.first.artworkUrl : '');

    return Playlist(
      id: json['playlist_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Playlist',
      owner: json['owner_name']?.toString() ?? 'Playlist owner',
      coverUrl: cover,
      trackCount: tracks.length,
      duration: formatDuration(totalDurationSeconds),
      description: json['description']?.toString(),
      isPublic: json['is_public'] == true,
      userId: json['user_id']?.toString(),
      tracks: tracks,
    );
  }
}
