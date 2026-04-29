// providers/tracks_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/services/track_service.dart';
import '../models/track.dart';
import '../services/track_service.dart';
import 'auth_providers.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final tracksServiceProvider = Provider<TracksService>((ref) {
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
  return TracksService(dio: dio);
});

// ─── GET /tracks/{track_id} ───────────────────────────────────────────────────

final trackProvider = FutureProvider.family<Track, String>((
  ref,
  String trackId,
) async {
  return ref.read(tracksServiceProvider).getTrack(trackId: trackId);
});

// ─── GET /search/tracks?keyword= ─────────────────────────────────────────────

final searchTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  String query,
) async {
  if (query.trim().isEmpty) return [];
  return ref.read(tracksServiceProvider).searchTracks(keyword: query.trim());
});

// ─── GET /users/{username}/tracks ────────────────────────────────────────────

final userTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  String username,
) async {
  return ref.read(tracksServiceProvider).getUserTracks(username: username);
});

// ─── GET /users/{username}/liked-tracks ──────────────────────────────────────

final userLikedTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  String username,
) async {
  return ref.read(tracksServiceProvider).getUserLikedTracks(username: username);
});

// ─── Feed State ───────────────────────────────────────────────────────────────

class FeedState {
  final List<Track> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;

  const FeedState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = true,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
  });

  FeedState copyWith({
    List<Track>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ─── GET /feed/following (paginated) ─────────────────────────────────────────

class FollowingFeedNotifier extends StateNotifier<FeedState> {
  final TracksService _service;

  FollowingFeedNotifier(this._service) : super(const FeedState()) {
    fetch();
  }

  Future<void> fetch({bool refresh = false}) async {
    if (state.isLoading || state.isFetchingMore) return;

    if (refresh) {
      state = const FeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final data = await _service.getFollowingFeed(limit: 20);
      final rawItems = data['items'] as List? ?? [];
      state = FeedState(
        items: rawItems
            .map((e) => Track.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: data['next_cursor']?.toString(),
        hasMore: data['has_more'] as bool? ?? false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _dioError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMore() async {
    if (!state.hasMore || state.isFetchingMore || state.nextCursor == null) {
      return;
    }

    state = state.copyWith(isFetchingMore: true);

    try {
      final data = await _service.getFollowingFeed(
        limit: 20,
        cursor: state.nextCursor,
      );
      final rawItems = data['items'] as List? ?? [];
      final newTracks = rawItems
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        items: [...state.items, ...newTracks],
        nextCursor: data['next_cursor']?.toString(),
        hasMore: data['has_more'] as bool? ?? false,
        isFetchingMore: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isFetchingMore: false, error: _dioError(e));
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
    }
  }

  /// Optimistically toggle like on a track in the feed.
  void toggleLike(String trackId) {
    state = state.copyWith(
      items: state.items.map((t) {
        if (t.trackId != trackId) return t;
        final liked = !(t.isLiked ?? false);
        return t.copyWith(
          isLiked: liked,
          likeCount: (t.likeCount ?? 0) + (liked ? 1 : -1),
        );
      }).toList(),
    );
  }

  Future<void> refresh() => fetch(refresh: true);
}

final followingFeedProvider =
    StateNotifierProvider<FollowingFeedNotifier, FeedState>((ref) {
      return FollowingFeedNotifier(ref.read(tracksServiceProvider));
    });

// ─── GET /feed/discover (paginated) ──────────────────────────────────────────

class DiscoverFeedNotifier extends StateNotifier<FeedState> {
  final TracksService _service;

  DiscoverFeedNotifier(this._service) : super(const FeedState()) {
    fetch();
  }

  Future<void> fetch({bool refresh = false}) async {
    if (state.isLoading || state.isFetchingMore) return;

    if (refresh) {
      state = const FeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final data = await _service.getDiscoverFeed(limit: 20);
      final rawItems = data['items'] as List? ?? [];
      state = FeedState(
        items: rawItems
            .map((e) => Track.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: data['next_cursor']?.toString(),
        hasMore: data['has_more'] as bool? ?? false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _dioError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMore() async {
    if (!state.hasMore || state.isFetchingMore || state.nextCursor == null) {
      return;
    }

    state = state.copyWith(isFetchingMore: true);

    try {
      final data = await _service.getDiscoverFeed(
        limit: 20,
        cursor: state.nextCursor,
      );
      final rawItems = data['items'] as List? ?? [];
      final newTracks = rawItems
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        items: [...state.items, ...newTracks],
        nextCursor: data['next_cursor']?.toString(),
        hasMore: data['has_more'] as bool? ?? false,
        isFetchingMore: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isFetchingMore: false, error: _dioError(e));
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
    }
  }

  void toggleLike(String trackId) {
    state = state.copyWith(
      items: state.items.map((t) {
        if (t.trackId != trackId) return t;
        final liked = !(t.isLiked ?? false);
        return t.copyWith(
          isLiked: liked,
          likeCount: (t.likeCount ?? 0) + (liked ? 1 : -1),
        );
      }).toList(),
    );
  }

  Future<void> refresh() => fetch(refresh: true);
}

final discoverFeedProvider =
    StateNotifierProvider<DiscoverFeedNotifier, FeedState>((ref) {
      return DiscoverFeedNotifier(ref.read(tracksServiceProvider));
    });

// ─── POST /tracks/{track_id}/plays ────────────────────────────────────────────

class RecordPlayNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> record({int? durationListenedSeconds}) async {
    try {
      await ref
          .read(tracksServiceProvider)
          .recordPlay(
            trackId: arg,
            durationListenedSeconds: durationListenedSeconds,
          );
    } on DioException catch (e) {
      throw Exception(_dioError(e));
    }
  }
}

final recordPlayProvider =
    AsyncNotifierProviderFamily<RecordPlayNotifier, void, String>(
      RecordPlayNotifier.new,
    );

// ─── POST /tracks/ — Create track ────────────────────────────────────────────

class CreateTrackNotifier extends AsyncNotifier<Track?> {
  @override
  Future<Track?> build() async => null;

  Future<Track> create({
    required String title,
    required String description,
    required String filePath,
    String? genre,
    String? tags,
    String? releaseDate,
    String visibility = 'public',
    String? coverImagePath,
  }) async {
    state = const AsyncLoading();
    try {
      final track = await ref
          .read(tracksServiceProvider)
          .createTrack(
            title: title,
            description: description,
            filePath: filePath,
            genre: genre,
            tags: tags,
            releaseDate: releaseDate,
            visibility: visibility,
            coverImagePath: coverImagePath,
          );
      state = AsyncData(track);
      return track;
    } on DioException catch (e) {
      final err = Exception(_dioError(e));
      state = AsyncError(err, StackTrace.current);
      throw err;
    }
  }
}

final createTrackProvider = AsyncNotifierProvider<CreateTrackNotifier, Track?>(
  CreateTrackNotifier.new,
);

// ─── PUT /tracks/{track_id} — Update track ────────────────────────────────────

class UpdateTrackNotifier extends FamilyAsyncNotifier<Track?, String> {
  @override
  Future<Track?> build(String arg) async => null;

  Future<Track> updateTrack({
    String? title,
    String? description,
    String? genre,
    List<String>? tags,
    String? releaseDate,
    String? fileUrl,
    String? visibility,
  }) async {
    state = const AsyncLoading();

    try {
      final track = await ref
          .read(tracksServiceProvider)
          .updateTrack(
            trackId: arg,
            title: title,
            description: description,
            genre: genre,
            tags: tags,
            releaseDate: releaseDate,
            fileUrl: fileUrl,
            visibility: visibility,
          );

      state = AsyncData(track);

      // refresh cached single track
      ref.invalidate(trackProvider(arg));

      return track;
    } on DioException catch (e) {
      final err = Exception(_dioError(e));
      state = AsyncError(err, StackTrace.current);
      throw err;
    }
  }
}

final updateTrackProvider =
    AsyncNotifierProviderFamily<UpdateTrackNotifier, Track?, String>(
      UpdateTrackNotifier.new,
    );

// ─── DELETE /tracks/{track_id} ────────────────────────────────────────────────

class DeleteTrackNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> delete() async {
    try {
      await ref.read(tracksServiceProvider).deleteTrack(trackId: arg);
      // Remove from both feeds so the UI updates instantly.
      ref.read(followingFeedProvider.notifier).refresh();
      ref.read(discoverFeedProvider.notifier).refresh();
    } on DioException catch (e) {
      throw Exception(_dioError(e));
    }
  }
}

final deleteTrackProvider =
    AsyncNotifierProviderFamily<DeleteTrackNotifier, void, String>(
      DeleteTrackNotifier.new,
    );

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _dioError(DioException e) {
  final status = e.response?.statusCode;
  if (status == 401) return 'You are not logged in.';
  if (status == 403) return 'You do not have permission to do this.';
  if (status == 404) return 'Track not found.';
  if (status == 413) return 'File is too large.';
  return 'Something went wrong. Please try again.';
}
