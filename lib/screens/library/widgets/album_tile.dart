import 'package:flutter/material.dart';
import '../../../models/album.dart';
import 'type_tile.dart';

class AlbumTile extends TypeTile {
  final Album album;

  const AlbumTile({
    super.key,
    required this.album,
    super.onTap,
    super.onMoreTap,
  });

  @override
  Widget get leading =>
      TileArtwork(url: album.artworkUrl, placeholderIcon: Icons.album);

  @override
  String get title => album.title;

  @override
  String get subtitle => album.artist;

  @override
  Widget get meta => TileMeta(['${album.releaseYear}', 'Album']);
}
