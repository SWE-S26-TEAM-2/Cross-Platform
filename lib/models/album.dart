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
}
