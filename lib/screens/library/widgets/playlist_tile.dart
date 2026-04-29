import 'package:flutter/material.dart';
import '../../../models/playlist.dart';
import 'type_tile.dart';

class PlaylistTile extends TypeTile {
  final Playlist playlist;

  const PlaylistTile({
    super.key,
    required this.playlist,
    super.onTap,
    super.onMoreTap,
  });

  @override
  Widget get leading =>
      TileArtwork(url: playlist.coverUrl, placeholderIcon: Icons.queue_music);

  @override
  String get title => playlist.name;

  @override
  String get subtitle => playlist.owner;

  @override
  Widget get meta =>
      TileMeta(['Playlist', '${playlist.trackCount} tracks', '']);
}
