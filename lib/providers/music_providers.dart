import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/music_service.dart';
import '../models/track.dart';

final musicServiceProvider = Provider<MusicService>((ref) {
  return MusicService();
});

final tracksProvider = FutureProvider<List<Track>>((ref) async {
  final service = ref.read(musicServiceProvider);
  return service.getTracks();
});

final searchProvider = FutureProvider.family<List<Track>, String>((
  ref,
  String query,
) async {
  if (query.isEmpty) return <Track>[];

  final service = ref.read(musicServiceProvider);
  return service.searchTracks(query);
});
