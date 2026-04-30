import 'package:flutter/material.dart';
import '../../../models/station.dart';
import 'type_tile.dart';

class StationTile extends TypeTile {
  final Station station;
  final String? duration; // pre-formatted e.g. "3:01:16"

  const StationTile({
    super.key,
    required this.station,
    this.duration,
    super.onTap,
    super.onMoreTap,
  });

  @override
  Widget get leading =>
      TileArtwork(url: station.artworkUrl, placeholderIcon: Icons.radio);

  @override
  String get title => station.title;

  @override
  String get subtitle => 'SoundCloud';

  @override
  Widget get meta => TileMeta([
    'Artist Station',
    duration ?? '',
    '${station.trackCount} tracks',
  ]);
}
