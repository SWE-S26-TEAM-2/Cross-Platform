import 'package:dio/dio.dart';
import '../models/playlist.dart';

class PlaylistService {
  final Dio _dio;
  final String baseUrl = 'https://streamline-swp.duckdns.org/api';

  PlaylistService({required Dio dio}) : _dio = dio;

  Options _authOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _readableError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }

    switch (status) {
      case 400:
        return 'Bad request. Please check the entered data.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You are not allowed to perform this action.';
      case 404:
        return 'Playlist not found.';
      case 422:
        return 'Invalid data sent to server.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }

  Future<List<Playlist>> getLikedPlaylists(String accessToken) async {
    try {
      final res = await _dio.get(
        '$baseUrl/playlists/liked',
        options: _authOptions(accessToken),
      );

      print('GET LIKED PLAYLISTS STATUS: ${res.statusCode}');
      print('GET LIKED PLAYLISTS DATA: ${res.data}');

      final data = res.data['data'];

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(Playlist.fromJson)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<Playlist> getPlaylistById({
    required String playlistId,
    required String accessToken,
  }) async {
    try {
      final res = await _dio.get(
        '$baseUrl/playlists/$playlistId',
        options: _authOptions(accessToken),
      );

      print('GET PLAYLIST STATUS: ${res.statusCode}');
      print('GET PLAYLIST DATA: ${res.data}');

      return Playlist.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<List<Playlist>> searchPlaylists({
    required String keyword,
    required String accessToken,
  }) async {
    try {
      final res = await _dio.get(
        '$baseUrl/search/playlists',
        queryParameters: {'keyword': keyword},
        options: _authOptions(accessToken),
      );

      print('SEARCH PLAYLISTS STATUS: ${res.statusCode}');
      print('SEARCH PLAYLISTS DATA: ${res.data}');

      final playlists = res.data['data']?['playlists'];

      if (playlists is List) {
        return playlists
            .whereType<Map<String, dynamic>>()
            .map(Playlist.fromJson)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<void> likePlaylist({
    required String playlistId,
    required String accessToken,
  }) async {
    try {
      final res = await _dio.post(
        '$baseUrl/playlists/$playlistId/like',
        options: _authOptions(accessToken),
      );

      print('LIKE PLAYLIST STATUS: ${res.statusCode}');
      print('LIKE PLAYLIST DATA: ${res.data}');
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<void> unlikePlaylist({
    required String playlistId,
    required String accessToken,
  }) async {
    try {
      final res = await _dio.delete(
        '$baseUrl/playlists/$playlistId/like',
        options: _authOptions(accessToken),
      );

      print('UNLIKE PLAYLIST STATUS: ${res.statusCode}');
      print('UNLIKE PLAYLIST DATA: ${res.data}');
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<void> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
    required String accessToken,
  }) async {
    try {
      final res = await _dio.post(
        '$baseUrl/playlists/$playlistId/tracks',
        data: {'track_id': trackId},
        options: _authOptions(accessToken),
      );

      print('ADD TRACK STATUS: ${res.statusCode}');
      print('ADD TRACK DATA: ${res.data}');
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<void> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
    required String accessToken,
  }) async {
    try {
      print('CALLING REMOVE TRACK ENDPOINT');
      print('$baseUrl/playlists/$playlistId/tracks/$trackId');

      final res = await _dio.delete(
        '$baseUrl/playlists/$playlistId/tracks/$trackId',
        options: _authOptions(accessToken),
      );

      print('REMOVE TRACK STATUS: ${res.statusCode}');
      print('REMOVE TRACK DATA: ${res.data}');
    } on DioException catch (e) {
      print('REMOVE TRACK ERROR STATUS: ${e.response?.statusCode}');
      print('REMOVE TRACK ERROR DATA: ${e.response?.data}');
      throw Exception(_readableError(e));
    }
  }

  Future<String?> uploadPlaylistCover({
    required String playlistId,
    required String filePath,
    required String accessToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final res = await _dio.post(
        '$baseUrl/playlists/$playlistId/cover',
        data: formData,
        options: _authOptions(accessToken),
      );

      print('UPLOAD COVER STATUS: ${res.statusCode}');
      print('UPLOAD COVER DATA: ${res.data}');

      return res.data['data']?['cover_photo_url'];
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<Playlist> createPlaylist({
    required String accessToken,
    required String name,
    String? description,
  }) async {
    try {
      final res = await _dio.post(
        '$baseUrl/playlists/',
        data: {'name': name, 'description': description ?? ''},
        options: _authOptions(accessToken),
      );

      print('CREATE PLAYLIST STATUS: ${res.statusCode}');
      print('CREATE PLAYLIST DATA: ${res.data}');

      return Playlist.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }
}
