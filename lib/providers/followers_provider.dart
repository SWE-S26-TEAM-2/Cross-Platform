// providers/followers_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/follower.dart';
import '../services/followers_service.dart';
import 'auth_providers.dart';
import 'package:dio/dio.dart';

// ─── Follow key ───────────────────────────────────────────────────────────────

typedef FollowKey = ({String userId, String username});

// ─── Service Provider ─────────────────────────────────────────────────────────

final followersServiceProvider = Provider<FollowersService>((ref) {
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
  return FollowersService(dio: dio);
});

// ─── GET /users/me/followers ──────────────────────────────────────────────────

final myFollowersProvider = FutureProvider<FollowerListResponse>((ref) async {
  return ref.watch(followersServiceProvider).getMyFollowers();
});

// ─── GET /users/me/following ──────────────────────────────────────────────────

final myFollowingProvider = FutureProvider<FollowingListResponse>((ref) async {
  return ref.watch(followersServiceProvider).getMyFollowing();
});

// ─── GET /users/{username}/followers ─────────────────────────────────────────

final userFollowersProvider =
    FutureProvider.family<FollowerListResponse, String>((ref, username) async {
      return ref
          .watch(followersServiceProvider)
          .getUserFollowers(username: username);
    });

// ─── GET /users/{username}/following ─────────────────────────────────────────

final userFollowingProvider =
    FutureProvider.family<FollowingListResponse, String>((ref, username) async {
      return ref
          .watch(followersServiceProvider)
          .getUserFollowing(username: username);
    });

// ─── POST/DELETE /users/{username}/follow ────────────────────────────────────

class FollowNotifier extends StateNotifier<_FollowState> {
  final FollowersService _service;
  final String _username;
  final Ref _ref;

  FollowNotifier({
    required FollowersService service,
    required String username,
    required bool initiallyFollowing,
    required Ref ref,
  }) : _service = service,
       _username = username,
       _ref = ref,
       super(_FollowState(isFollowing: initiallyFollowing));

  Future<void> toggle() async {
    if (state.isLoading) return;

    final prev = state.isFollowing;
    state = state.copyWith(isFollowing: !prev, isLoading: true);

    try {
      if (prev) {
        await _service.unfollowUser(username: _username);
      } else {
        await _service.followUser(username: _username);
      }
      state = state.copyWith(isLoading: false);
      _ref.invalidate(myFollowingProvider);
    } catch (_) {
      state = state.copyWith(isFollowing: prev, isLoading: false);
    }
  }
}

class _FollowState {
  final bool isFollowing;
  final bool isLoading;

  const _FollowState({required this.isFollowing, this.isLoading = false});

  _FollowState copyWith({bool? isFollowing, bool? isLoading}) => _FollowState(
    isFollowing: isFollowing ?? this.isFollowing,
    isLoading: isLoading ?? this.isLoading,
  );
}

// Keyed by userId — one instance per user shared across the whole app.
// Username is carried in the key for the API call.
final followProvider =
    StateNotifierProvider.family<FollowNotifier, _FollowState, FollowKey>((
      ref,
      key,
    ) {
      final followingAsync = ref.watch(myFollowingProvider);
      final initiallyFollowing = followingAsync.maybeWhen(
        data: (res) => res.following.any((f) => f.userId == key.userId),
        orElse: () => false,
      );

      return FollowNotifier(
        service: ref.read(followersServiceProvider),
        username: key.username,
        initiallyFollowing: initiallyFollowing,
        ref: ref,
      );
    });

// ─── POST/DELETE /users/{username}/block ──────────────────────────────────────

class BlockNotifier extends StateNotifier<_BlockState> {
  final FollowersService _service;
  final String _username;

  BlockNotifier({required FollowersService service, required String username})
    : _service = service,
      _username = username,
      super(const _BlockState(isBlocked: false));

  Future<void> toggle() async {
    if (state.isLoading) {
      return;
    }

    final prev = state.isBlocked;
    state = state.copyWith(isBlocked: !prev, isLoading: true);

    try {
      if (prev) {
        await _service.unblockUser(username: _username);
      } else {
        await _service.blockUser(username: _username);
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isBlocked: prev, isLoading: false);
    }
  }
}

class _BlockState {
  final bool isBlocked;
  final bool isLoading;

  const _BlockState({required this.isBlocked, this.isLoading = false});

  _BlockState copyWith({bool? isBlocked, bool? isLoading}) => _BlockState(
    isBlocked: isBlocked ?? this.isBlocked,
    isLoading: isLoading ?? this.isLoading,
  );
}

final blockProvider =
    StateNotifierProvider.family<BlockNotifier, _BlockState, String>(
      (ref, username) => BlockNotifier(
        service: ref.read(followersServiceProvider),
        username: username,
      ),
    );
