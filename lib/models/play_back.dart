class Playback {
  final String trackId;
  final String title;
  final String description;
  final String streamUrl;
  final String? expiresIn;
  final String contentType;
  final int playCount;
  final String processingStatus;
  final String? genre;
  final List<String> tags;
  final String? releaseDate;
  final int? durationSeconds;
  final Waveform? waveform;

  Playback({
    required this.trackId,
    required this.title,
    required this.description,
    required this.streamUrl,
    this.expiresIn,
    required this.contentType,
    required this.playCount,
    required this.processingStatus,
    this.genre,
    this.tags = const [],
    this.releaseDate,
    this.durationSeconds,
    this.waveform,
  });

  factory Playback.fromJson(Map<String, dynamic> json) {
    return Playback(
      trackId: json['track_id'] as String,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      streamUrl: json['stream_url'] as String,
      expiresIn: json['expires_in']?.toString(),
      contentType: json['content_type'] ?? 'audio/mpeg',
      playCount: json['play_count'] ?? 0,
      processingStatus: json['processing_status'] ?? '',
      genre: json['genre'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      releaseDate: json['release_date'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      waveform: json['waveform'] != null
          ? Waveform.fromJson(json['waveform'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Full playable URL — prepend base if relative path
  String get fullStreamUrl {
    if (streamUrl.startsWith('http')) return streamUrl;
    return 'http://68.210.102.76$streamUrl';
  }
}

class Waveform {
  final int sampleCount;
  final List<double> peaks;

  Waveform({required this.sampleCount, required this.peaks});

  factory Waveform.fromJson(Map<String, dynamic> json) {
    return Waveform(
      sampleCount: json['sample_count'] ?? 0,
      peaks: (json['peaks'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
