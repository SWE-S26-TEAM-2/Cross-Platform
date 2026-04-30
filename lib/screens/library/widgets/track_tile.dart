import 'package:flutter/material.dart';
import '../../../models/track.dart';
import 'type_tile.dart';

class TrackTile extends TypeTile {
  final Track track;

  const TrackTile({
    super.key,
    required this.track,
    super.onTap,
    super.onMoreTap,
  });

  @override
  Widget get leading => TileArtwork(url: track.artworkUrl ?? '');

  @override
  String get title => track.title;

  @override
  String get subtitle => track.formattedArtist;

  @override
  Widget get meta => TileMeta([_formatDuration(track.durationSeconds ?? 0)]);

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
