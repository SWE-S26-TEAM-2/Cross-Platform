// services/followers_service.dart

import 'package:dio/dio.dart';
import '../models/follower.dart';

class FollowersService {
  final Dio _dio;
  static const String _base = 'https://streamline-swp.duckdns.org/api';

  FollowersService({required Dio dio}) : _dio = dio;

  // ── POST /users/{username}/follow ─────────────────────────────────────────

  Future<void> followUser({required String username}) async {
    await _dio.post('$_base/users/$username/follow');
  }

  // ── DELETE /users/{username}/follow ──────────────────────────────────────

  Future<void> unfollowUser({required String username}) async {
    await _dio.delete('$_base/users/$username/follow');
  }

  // ── POST /users/{username}/block ──────────────────────────────────────────

  Future<void> blockUser({required String username}) async {
    await _dio.post('$_base/users/$username/block');
  }

  // ── DELETE /users/{username}/block ────────────────────────────────────────

  Future<void> unblockUser({required String username}) async {
    await _dio.delete('$_base/users/$username/block');
  }

  // ── GET /users/me/followers ───────────────────────────────────────────────

  Future<FollowerListResponse> getMyFollowers() async {
    final res = await _dio.get('$_base/users/me/followers');
    return FollowerListResponse.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  // ── GET /users/me/following ───────────────────────────────────────────────

  Future<FollowingListResponse> getMyFollowing() async {
    final res = await _dio.get('$_base/users/me/following');
    return FollowingListResponse.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  // ── GET /users/{username}/followers ──────────────────────────────────────

  Future<FollowerListResponse> getUserFollowers({
    required String username,
  }) async {
    final res = await _dio.get('$_base/users/$username/followers');
    return FollowerListResponse.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  // ── GET /users/{username}/following ──────────────────────────────────────

  Future<FollowingListResponse> getUserFollowing({
    required String username,
  }) async {
    final res = await _dio.get('$_base/users/$username/following');
    return FollowingListResponse.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }
}
