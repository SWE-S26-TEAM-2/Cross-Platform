import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../services/user_profile_services.dart';
import 'auth_providers.dart';

final userProfileServiceProvider = Provider<UserService>((ref) {
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
  return UserService(dio: dio);
});

Track _parseItem(dynamic item) {
  if (item is! Map<String, dynamic>) {
    return const Track(
      trackId: '',
      title: 'Unknown',
      streamUrl: '',
      visibility: 'public',
      processingStatus: '',
      playCount: 0,
    );
  }
  // Support both flat track data and { "track": {...}, "played_at": "..." }
  final trackMap = item['track'] is Map<String, dynamic>
      ? item['track'] as Map<String, dynamic>
      : item;
  return Track.fromJson(trackMap);
}

final recentlyPlayedProvider = FutureProvider<List<Track>>((ref) async {
  final token = ref.watch(authProvider).tokens?.accessToken;
  if (token == null || token.isEmpty) {
    return [];
  }
  final service = ref.read(userProfileServiceProvider);
  final data = await service.getRecentlyPlayed(accessToken: token);
  return data.map(_parseItem).toList();
});

final listeningHistoryProvider = FutureProvider<List<Track>>((ref) async {
  final token = ref.watch(authProvider).tokens?.accessToken;
  if (token == null || token.isEmpty) {
    return [];
  }
  final service = ref.read(userProfileServiceProvider);
  final data = await service.getListeningHistory(accessToken: token);
  return data.map(_parseItem).toList();
});
