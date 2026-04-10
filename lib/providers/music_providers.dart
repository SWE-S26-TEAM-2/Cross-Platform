import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/music_service.dart';

final musicServiceProvider = Provider((ref) => MusicService());

final tracksProvider = FutureProvider((ref) async {
  final service = ref.read(musicServiceProvider);
  return service.getTracks();
});

final feedProvider = FutureProvider((ref) async {
  final service = ref.read(musicServiceProvider);
  return service.getFeed();
});

final vibesProvider = FutureProvider((ref) async {
  final service = ref.read(musicServiceProvider);
  return service.getVibes();
});