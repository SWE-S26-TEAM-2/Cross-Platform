class Playlist {
  final String id;
  final String name;
  final String owner;
  final String coverUrl;
  final int trackCount;
  final String duration;

  const Playlist({
    required this.id,
    required this.name,
    required this.owner,
    required this.coverUrl,
    required this.trackCount,
    required this.duration,
  });
}
