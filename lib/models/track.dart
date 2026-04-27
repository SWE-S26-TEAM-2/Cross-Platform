class Track {
  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final int likeCount;
  final int duration;
  final String audioPath;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.likeCount,
    required this.duration,
    required this.audioPath,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: json['display_name']?.toString() ?? '', // uploader's name
      artworkUrl: json['cover_image']?.toString() ?? '',
      likeCount: json['like_count'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      audioPath: json['file_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artworkUrl': artworkUrl,
      'likeCount': likeCount,
      'duration': duration,
      'audioPath': audioPath,
    };
  }
}
