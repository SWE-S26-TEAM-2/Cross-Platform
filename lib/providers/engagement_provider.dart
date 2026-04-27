import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/comment.dart';
import 'package:my_project/services/engagement_service.dart';
import 'auth_providers.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final engagementServiceProvider = Provider<EngagementService>((ref) {
  final token = ref.watch(authProvider).tokens?.accessToken ?? '';
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  );
  return EngagementService(dio: dio);
});

// ─── POST/DELETE /tracks/{track_id}/like ─────────────────────────────────────

class TrackLikeNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> like() async {
    try {
      await ref.read(engagementServiceProvider).likeTrack(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401)
        throw Exception('You are not logged in.');
      if (e.response?.statusCode == 404) throw Exception('Track not found.');
      throw Exception('Could not like track. Please try again.');
    }
  }

  Future<void> unlike() async {
    try {
      await ref.read(engagementServiceProvider).unlikeTrack(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401)
        throw Exception('You are not logged in.');
      if (e.response?.statusCode == 404) throw Exception('Track not found.');
      throw Exception('Could not unlike track. Please try again.');
    }
  }
}

final trackLikeProvider =
    AsyncNotifierProviderFamily<TrackLikeNotifier, void, String>(
      TrackLikeNotifier.new,
    );

// ─── POST/DELETE /playlists/{playlist_id}/like ────────────────────────────────

class PlaylistLikeNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> like() async {
    try {
      await ref.read(engagementServiceProvider).likePlaylist(playlistId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401)
        throw Exception('You are not logged in.');
      if (e.response?.statusCode == 404) throw Exception('Playlist not found.');
      throw Exception('Could not like playlist. Please try again.');
    }
  }

  Future<void> unlike() async {
    try {
      await ref.read(engagementServiceProvider).unlikePlaylist(playlistId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401)
        throw Exception('You are not logged in.');
      if (e.response?.statusCode == 404) throw Exception('Playlist not found.');
      throw Exception('Could not unlike playlist. Please try again.');
    }
  }
}

final playlistLikeProvider =
    AsyncNotifierProviderFamily<PlaylistLikeNotifier, void, String>(
      PlaylistLikeNotifier.new,
    );

// ─── GET /tracks/{track_id}/comments ─────────────────────────────────────────

class CommentsNotifier extends FamilyAsyncNotifier<List<Comment>, String> {
  @override
  Future<List<Comment>> build(String arg) async {
    try {
      return await ref
          .read(engagementServiceProvider)
          .getComments(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Could not load comments. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> addComment({
    required String content,
    int? timestampInTrack,
    String? parentCommentId,
  }) async {
    try {
      await ref
          .read(engagementServiceProvider)
          .addComment(
            trackId: arg,
            content: content,
            timestampInTrack: timestampInTrack,
            parentCommentId: parentCommentId,
          );
      ref.invalidateSelf();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401)
        throw Exception('You are not logged in.');
      if (e.response?.statusCode == 404) throw Exception('Track not found.');
      throw Exception('Could not post comment. Please try again.');
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(engagementServiceProvider).getComments(trackId: arg),
    );
  }
}

final commentsProvider =
    AsyncNotifierProviderFamily<CommentsNotifier, List<Comment>, String>(
      CommentsNotifier.new,
    );
