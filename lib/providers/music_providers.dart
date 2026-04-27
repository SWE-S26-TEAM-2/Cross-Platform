import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/music_service.dart';
import '../models/track.dart';
import 'auth_providers.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────
// Auth token injected via interceptor so all track endpoints are authenticated

final musicServiceProvider = Provider<MusicService>((ref) {
  final token = ref.watch(authProvider).tokens?.accessToken ?? '';
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  return MusicService(dio: dio);
});

// ─── GET /search/tracks ───────────────────────────────────────────────────────

final searchTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  String query,
) async {
  if (query.isEmpty) return <Track>[];
  return ref.read(musicServiceProvider).searchTracks(query);
});

// ─── GET /tracks/{track_id} ───────────────────────────────────────────────────

final trackProvider = FutureProvider.family<Track, String>((
  ref,
  String trackId,
) async {
  return ref.read(musicServiceProvider).getTrack(trackId: trackId);
});

// ─── POST /tracks/{track_id}/plays ────────────────────────────────────────────

class RecordPlayNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> record({int? durationListenedSeconds}) async {
    await ref
        .read(musicServiceProvider)
        .recordPlay(
          trackId: arg,
          durationListenedSeconds: durationListenedSeconds,
        );
  }
}

final recordPlayProvider =
    AsyncNotifierProviderFamily<RecordPlayNotifier, void, String>(
      RecordPlayNotifier.new,
    );
