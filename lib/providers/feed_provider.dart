import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/feee_service.dart';
import '../models/feed_response.dart';
import 'auth_providers.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final feedServiceProvider = Provider<FeedService>((ref) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authProvider).tokens?.accessToken ?? '';
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  );
  return FeedService(dio: dio);
});

// ─── Following Feed Notifier ──────────────────────────────────────────────────

class FollowingFeedNotifier extends AsyncNotifier<FeedState> {
  bool _isLoadingMore = false;

  /// build() auto-fetches — watching the provider is enough to trigger the load
  @override
  Future<FeedState> build() async {
    final response = await ref
        .read(feedServiceProvider)
        .getFollowingFeed(limit: 20);
    return FeedState(
      items: response.data.items,
      hasMore: response.data.hasMore,
      nextCursor: response.data.nextCursor,
    );
  }

  Future<void> loadMore({int limit = 20}) async {
    if (_isLoadingMore) return;
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;
    if (currentState.nextCursor == null) return;

    _isLoadingMore = true;
    final previousItems = currentState.items;

    try {
      final response = await ref
          .read(feedServiceProvider)
          .getFollowingFeed(limit: limit, cursor: currentState.nextCursor);

      state = AsyncData(
        FeedState(
          items: [...previousItems, ...response.data.items],
          hasMore: response.data.hasMore,
          nextCursor: response.data.nextCursor,
        ),
      );
    } on DioException catch (e) {
      state = AsyncData(
        FeedState(
          items: previousItems,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
          paginationError:
              'Failed to load more: ${e.response?.statusCode ?? e.message}',
        ),
      );
    } catch (e) {
      state = AsyncData(
        FeedState(
          items: previousItems,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
          paginationError: 'Failed to load more: $e',
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Invalidating re-runs build() from scratch
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

// ─── Discover Feed Notifier ───────────────────────────────────────────────────

class DiscoverFeedNotifier extends AsyncNotifier<FeedState> {
  bool _isLoadingMore = false;

  @override
  Future<FeedState> build() async {
    final response = await ref
        .read(feedServiceProvider)
        .getDiscoverFeed(limit: 20);
    return FeedState(
      items: response.data.items,
      hasMore: response.data.hasMore,
      nextCursor: response.data.nextCursor,
    );
  }

  Future<void> loadMore({int limit = 20}) async {
    if (_isLoadingMore) return;
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;
    if (currentState.nextCursor == null) return;

    _isLoadingMore = true;
    final previousItems = currentState.items;

    try {
      final response = await ref
          .read(feedServiceProvider)
          .getDiscoverFeed(limit: limit, cursor: currentState.nextCursor);

      state = AsyncData(
        FeedState(
          items: [...previousItems, ...response.data.items],
          hasMore: response.data.hasMore,
          nextCursor: response.data.nextCursor,
        ),
      );
    } on DioException catch (e) {
      state = AsyncData(
        FeedState(
          items: previousItems,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
          paginationError:
              'Failed to load more: ${e.response?.statusCode ?? e.message}',
        ),
      );
    } catch (e) {
      state = AsyncData(
        FeedState(
          items: previousItems,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
          paginationError: 'Failed to load more: $e',
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

// ─── Cached Discover Feed Notifier ────────────────────────────────────────────

class CachedDiscoverFeedNotifier extends AsyncNotifier<CachedFeedState> {
  bool _isLoadingMore = false;

  @override
  Future<CachedFeedState> build() async {
    final response = await ref
        .read(feedServiceProvider)
        .getDiscoverFeedCached(limit: 20);
    return CachedFeedState(
      items: response.data.items,
      hasMore: response.data.hasMore,
      nextCursor: response.data.nextCursor,
      cacheHit: response.cacheHit,
      queryTimeMs: response.queryTimeMs,
      cachedAt: response.cachedAt != null
          ? DateTime.tryParse(response.cachedAt!)
          : null,
      cacheTtlSeconds: response.cacheTtlSeconds,
    );
  }

  Future<void> loadMore({int limit = 20}) async {
    if (_isLoadingMore) return;
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;
    if (currentState.nextCursor == null) return;

    _isLoadingMore = true;
    final previousItems = currentState.items;

    try {
      final response = await ref
          .read(feedServiceProvider)
          .getDiscoverFeedCached(limit: limit, cursor: currentState.nextCursor);

      state = AsyncData(
        CachedFeedState(
          items: [...previousItems, ...response.data.items],
          hasMore: response.data.hasMore,
          nextCursor: response.data.nextCursor,
          cacheHit: response.cacheHit,
          queryTimeMs: response.queryTimeMs,
          cachedAt: response.cachedAt != null
              ? DateTime.tryParse(response.cachedAt!)
              : null,
          cacheTtlSeconds: response.cacheTtlSeconds,
        ),
      );
    } on DioException catch (e) {
      state = AsyncData(
        CachedFeedState(
          items: previousItems,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
          cacheHit: currentState.cacheHit,
          queryTimeMs: currentState.queryTimeMs,
          cachedAt: currentState.cachedAt,
          cacheTtlSeconds: currentState.cacheTtlSeconds,
          paginationError:
              'Failed to load more: ${e.response?.statusCode ?? e.message}',
        ),
      );
    } catch (e) {
      state = AsyncData(
        CachedFeedState(
          items: previousItems,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
          cacheHit: currentState.cacheHit,
          queryTimeMs: currentState.queryTimeMs,
          cachedAt: currentState.cachedAt,
          cacheTtlSeconds: currentState.cacheTtlSeconds,
          paginationError: 'Failed to load more: $e',
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> clearCache() async {
    await ref.read(feedServiceProvider).clearFeedCache();
  }
}

// ─── State Classes ────────────────────────────────────────────────────────────

class FeedState {
  final List<FeedTrackItem> items;
  final bool hasMore;
  final String? nextCursor;
  final String? paginationError;

  const FeedState({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    this.paginationError,
  });

  @override
  bool operator ==(Object other) =>
      other is FeedState &&
      other.hasMore == hasMore &&
      other.nextCursor == nextCursor &&
      other.paginationError == paginationError &&
      listEquals(other.items, items);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(items), hasMore, nextCursor, paginationError);
}

class CachedFeedState extends FeedState {
  final bool cacheHit;
  final double? queryTimeMs;
  final DateTime? cachedAt;
  final int? cacheTtlSeconds;

  const CachedFeedState({
    required super.items,
    required super.hasMore,
    super.nextCursor,
    super.paginationError,
    required this.cacheHit,
    this.queryTimeMs,
    this.cachedAt,
    this.cacheTtlSeconds,
  });

  bool get isFromCache => cacheHit;

  bool get isCacheExpired {
    if (cachedAt == null || cacheTtlSeconds == null) return true;
    return DateTime.now().difference(cachedAt!).inSeconds > cacheTtlSeconds!;
  }

  @override
  bool operator ==(Object other) =>
      other is CachedFeedState &&
      super == other &&
      other.cacheHit == cacheHit &&
      other.queryTimeMs == queryTimeMs &&
      other.cachedAt == cachedAt &&
      other.cacheTtlSeconds == cacheTtlSeconds;

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    cacheHit,
    queryTimeMs,
    cachedAt,
    cacheTtlSeconds,
  );
}

// ─── Providers ────────────────────────────────────────────────────────────────

final followingFeedProvider =
    AsyncNotifierProvider<FollowingFeedNotifier, FeedState>(
      FollowingFeedNotifier.new,
    );

final discoverFeedProvider =
    AsyncNotifierProvider<DiscoverFeedNotifier, FeedState>(
      DiscoverFeedNotifier.new,
    );

final cachedDiscoverFeedProvider =
    AsyncNotifierProvider<CachedDiscoverFeedNotifier, CachedFeedState>(
      CachedDiscoverFeedNotifier.new,
    );
