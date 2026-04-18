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

// ─── POST/DELETE /likes/tracks/{track_id} ────────────────────────────────────

class TrackLikeNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> like() async {
    try {
      await ref.read(engagementServiceProvider).likeTrack(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not like track. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> unlike() async {
    try {
      await ref.read(engagementServiceProvider).unlikeTrack(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not unlike track. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final trackLikeProvider =
    AsyncNotifierProviderFamily<TrackLikeNotifier, void, String>(
      TrackLikeNotifier.new,
    );

// ─── POST/DELETE /reposts/tracks/{track_id} ──────────────────────────────────

class TrackRepostNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> repost() async {
    try {
      await ref.read(engagementServiceProvider).repostTrack(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not repost track. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> removeRepost() async {
    try {
      await ref.read(engagementServiceProvider).removeRepost(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not remove repost. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final trackRepostProvider =
    AsyncNotifierProviderFamily<TrackRepostNotifier, void, String>(
      TrackRepostNotifier.new,
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
      if (e.response?.statusCode == 404) {
        return []; // no comments yet
      }
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
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not post comment. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
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
