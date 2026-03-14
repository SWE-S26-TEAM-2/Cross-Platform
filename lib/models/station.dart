class Station {
  final String id;
  final String title;
  final String artworkUrl;
  final String basedOn;
  final String mood;
  final int likeCount;
  final int trackCount;
  final List<String> trackIds;

  const Station({
    required this.id,
    required this.title,
    required this.artworkUrl,
    required this.basedOn,
    required this.mood,
    required this.likeCount,
    required this.trackCount,
    this.trackIds = const [],
  });
}
