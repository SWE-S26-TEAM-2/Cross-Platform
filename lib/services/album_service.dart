import 'package:dio/dio.dart';
import '../models/album.dart';

class AlbumService {
  final Dio _dio;
  final String baseUrl = 'https://streamline-swp.duckdns.org/api';

  AlbumService({required Dio dio}) : _dio = dio;

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  String _readableError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }

    switch (status) {
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You are not allowed to perform this action.';
      case 404:
        return 'Album not found.';
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

  // Safely extract an Album from a response data field (handles both flat and
  // nested shapes: { data: {...} } and { data: { album: {...} } }).
  Album _albumFromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['album_id'] != null || data['id'] != null) {
        return Album.fromJson(data);
      }
      for (final key in ['album', 'data']) {
        if (data[key] is Map<String, dynamic>) {
          return Album.fromJson(data[key] as Map<String, dynamic>);
        }
      }
    }
    return Album.fromJson(data as Map<String, dynamic>);
  }

  // Safely extract a list of Albums from a response data field.
  List<Album> _albumListFromData(dynamic data) {
    List raw;
    if (data is List) {
      raw = data;
    } else if (data is Map && data['items'] is List) {
      raw = data['items'] as List;
    } else if (data is Map && data['albums'] is List) {
      raw = data['albums'] as List;
    } else {
      raw = [];
    }
    return raw.whereType<Map<String, dynamic>>().map(Album.fromJson).toList();
  }

  /// GET /albums/liked
  Future<List<Album>> getLikedAlbums(String accessToken) async {
    try {
      final res = await _dio.get(
        '$baseUrl/albums/liked',
        options: _authOptions(accessToken),
      );
      return _albumListFromData(res.data['data']);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// GET /albums/{album_id}
  Future<Album> getAlbumById({
    required String albumId,
    required String accessToken,
  }) async {
    try {
      final res = await _dio.get(
        '$baseUrl/albums/$albumId',
        options: _authOptions(accessToken),
      );
      return _albumFromData(res.data['data']);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// POST /albums/
  Future<Album> createAlbum({
    required String accessToken,
    required String title,
    String? description,
    String? releaseDate,
    String? genre,
  }) async {
    try {
      final res = await _dio.post(
        '$baseUrl/albums/',
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (releaseDate != null) 'release_date': releaseDate,
          if (genre != null) 'genre': genre,
        },
        options: _authOptions(accessToken),
      );
      return _albumFromData(res.data['data']);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// PATCH /albums/{album_id}
  Future<Album> updateAlbum({
    required String albumId,
    required String accessToken,
    String? title,
    String? description,
    String? releaseDate,
    String? genre,
  }) async {
    try {
      final res = await _dio.patch(
        '$baseUrl/albums/$albumId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (releaseDate != null) 'release_date': releaseDate,
          if (genre != null) 'genre': genre,
        },
        options: _authOptions(accessToken),
      );
      return _albumFromData(res.data['data']);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// DELETE /albums/{album_id}
  Future<void> deleteAlbum({
    required String albumId,
    required String accessToken,
  }) async {
    try {
      await _dio.delete(
        '$baseUrl/albums/$albumId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// POST /albums/{album_id}/cover  (multipart/form-data)
  Future<String?> uploadAlbumCover({
    required String albumId,
    required String accessToken,
    required String filePath,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final res = await _dio.post(
        '$baseUrl/albums/$albumId/cover',
        data: formData,
        options: _authOptions(accessToken),
      );
      final d = res.data['data'];
      return (d is Map)
          ? (d['cover_photo_url'] ?? d['cover_url'])?.toString()
          : null;
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// POST /albums/{album_id}/like
  Future<void> likeAlbum({
    required String albumId,
    required String accessToken,
  }) async {
    try {
      await _dio.post(
        '$baseUrl/albums/$albumId/like',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// DELETE /albums/{album_id}/like
  Future<void> unlikeAlbum({
    required String albumId,
    required String accessToken,
  }) async {
    try {
      await _dio.delete(
        '$baseUrl/albums/$albumId/like',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// POST /albums/{album_id}/tracks  — body: { track_id: uuid }
  Future<void> addTrackToAlbum({
    required String albumId,
    required String trackId,
    required String accessToken,
  }) async {
    try {
      await _dio.post(
        '$baseUrl/albums/$albumId/tracks',
        data: {'track_id': trackId},
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// DELETE /albums/{album_id}/tracks/{track_id}
  Future<void> removeTrackFromAlbum({
    required String albumId,
    required String trackId,
    required String accessToken,
  }) async {
    try {
      await _dio.delete(
        '$baseUrl/albums/$albumId/tracks/$trackId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  /// PUT /albums/{album_id}/tracks/reorder  — body: { track_ids: [uuid, ...] }
  Future<void> reorderAlbumTracks({
    required String albumId,
    required List<String> trackIds,
    required String accessToken,
  }) async {
    try {
      await _dio.put(
        '$baseUrl/albums/$albumId/tracks/reorder',
        data: {'track_ids': trackIds},
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }
}
