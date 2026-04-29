import 'package:dio/dio.dart';
import 'dart:io';
import '../models/user.dart';

class UserService {
  final Dio _dio;
  static const String _baseUrl = 'https://streamline-swp.duckdns.org/api';

  UserService({required Dio dio}) : _dio = dio;

  // GET /users/me
  Future<User> getMe(String accessToken) async {
    final res = await _dio.get(
      '$_baseUrl/users/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return User.fromJson(res.data['data']);
  }

  // GET /users/{username}
  // NOTE: API uses username (not user ID) as the path param
  Future<User> getUserByUsername(String username) async {
    final res = await _dio.get('$_baseUrl/users/$username');
    return User.fromJson(res.data['data']);
  }

  // PATCH /users/me
  Future<User> updateMe({
    required String accessToken,
    String? username,
    String? displayName,
    String? bio,
    String? location,
    String? accountType,
  }) async {
    final res = await _dio.patch(
      '$_baseUrl/users/me',
      data: {
        if (username != null) 'username': username,
        if (displayName != null) 'display_name': displayName,
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (accountType != null) 'account_type': accountType,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return User.fromJson(res.data['data']);
  }

  // PATCH /users/me/privacy
  Future<bool> updatePrivacy({
    required String accessToken,
    required bool isPrivate,
  }) async {
    final res = await _dio.patch(
      '$_baseUrl/users/me/privacy',
      data: {'is_private': isPrivate},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data']['is_private'] as bool;
  }

  // PUT /users/me/avatar  (multipart/form-data)
  Future<String?> uploadAvatar({
    required String accessToken,
    required String filePath,
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _dio.put(
      '$_baseUrl/users/me/avatar',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data']?['profile_picture']?.toString();
  }

  // PUT /users/me/cover  (multipart/form-data)
  Future<String?> uploadCover({
    required String accessToken,
    required String filePath,
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _dio.put(
      '$_baseUrl/users/me/cover',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data']?['cover_photo']?.toString();
  }

  // GET /users/me/social-links
  Future<List<Map<String, String>>> getSocialLinks(String accessToken) async {
    final res = await _dio.get(
      '$_baseUrl/users/me/social-links',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final List data = res.data['data'] ?? [];
    return data
        .map<Map<String, String>>(
          (e) => {
            'platform': e['platform'].toString(),
            'url': e['url'].toString(),
          },
        )
        .toList();
  }

  // PUT /users/me/social-links
  // socialLinks: [{'platform': 'instagram', 'url': 'https://...'}, ...]
  // Send empty list to clear all links. Max 5 links.
  Future<void> updateSocialLinks({
    required String accessToken,
    required List<Map<String, String>> socialLinks,
  }) async {
    await _dio.put(
      '$_baseUrl/users/me/social-links',
      data: {'social_links': socialLinks},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // GET /users/{username}/tracks
  Future<List<dynamic>> getUserTracks({
    required String accessToken,
    required String username,
  }) async {
    final res = await _dio.get(
      '$_baseUrl/users/$username/tracks',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }

  // GET /users/{username}/liked-tracks
  Future<List<dynamic>> getUserLikedTracks({
    required String accessToken,
    required String username,
  }) async {
    final res = await _dio.get(
      '$_baseUrl/users/$username/liked-tracks',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }

  // GET /users/me/recently-played
  Future<List<dynamic>> getRecentlyPlayed({
    required String accessToken,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      '$_baseUrl/users/me/recently-played',
      queryParameters: {'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }

  // GET /users/me/listening-history
  Future<List<dynamic>> getListeningHistory({
    required String accessToken,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      '$_baseUrl/users/me/listening-history',
      queryParameters: {'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }

  // POST /users/{username}/follow
  Future<void> followUser({
    required String accessToken,
    required String username,
  }) async {
    await _dio.post(
      '$_baseUrl/users/$username/follow',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // DELETE /users/{username}/follow
  Future<void> unfollowUser({
    required String accessToken,
    required String username,
  }) async {
    await _dio.delete(
      '$_baseUrl/users/$username/follow',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // POST /users/{username}/block
  Future<void> blockUser({
    required String accessToken,
    required String username,
  }) async {
    await _dio.post(
      '$_baseUrl/users/$username/block',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // DELETE /users/{username}/block
  Future<void> unblockUser({
    required String accessToken,
    required String username,
  }) async {
    await _dio.delete(
      '$_baseUrl/users/$username/block',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // GET /users/me/followers
  Future<List<dynamic>> getMyFollowers(String accessToken) async {
    final res = await _dio.get(
      '$_baseUrl/users/me/followers',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }

  // GET /users/me/following
  Future<List<dynamic>> getMyFollowing(String accessToken) async {
    final res = await _dio.get(
      '$_baseUrl/users/me/following',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }

  // GET /users/{username}/followers
  Future<List<dynamic>> getUserFollowers({
    required String accessToken,
    required String username,
  }) async {
    final res = await _dio.get(
      '$_baseUrl/users/$username/followers',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }

  // GET /users/{username}/following
  Future<List<dynamic>> getUserFollowing({
    required String accessToken,
    required String username,
  }) async {
    final res = await _dio.get(
      '$_baseUrl/users/$username/following',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data['data'] ?? [];
  }
}
