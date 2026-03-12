//import 'package:flutter/material.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final int likeCount;
  final int duration;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.likeCount,
    required this.duration,
  });
}
