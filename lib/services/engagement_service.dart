import 'package:dio/dio.dart';
import '../models/comment.dart';

class EngagementService {
  final Dio _dio;
  static const String _baseUrl = 'https://streamline-swp.duckdns.org/api';

  EngagementService({required Dio dio}) : _dio = dio;

  // POST /tracks/{track_id}/like  (note: NOT /likes/tracks/{track_id})
  Future<void> likeTrack({required String trackId}) async {
    await _dio.post('$_baseUrl/tracks/$trackId/like');
  }

  // DELETE /tracks/{track_id}/like
  Future<void> unlikeTrack({required String trackId}) async {
    await _dio.delete('$_baseUrl/tracks/$trackId/like');
  }

  // POST /playlists/{playlist_id}/like
  Future<void> likePlaylist({required String playlistId}) async {
    await _dio.post('$_baseUrl/playlists/$playlistId/like');
  }

  // DELETE /playlists/{playlist_id}/like
  Future<void> unlikePlaylist({required String playlistId}) async {
    await _dio.delete('$_baseUrl/playlists/$playlistId/like');
  }

  // GET /playlists/liked
  Future<List<dynamic>> getLikedPlaylists() async {
    final response = await _dio.get('$_baseUrl/playlists/liked');
    return response.data['data'] ?? [];
  }

  // GET /tracks/{track_id}/comments
  Future<List<Comment>> getComments({
    required String trackId,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/tracks/$trackId/comments',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final List data = response.data['data'] ?? [];
    return data.map((e) => Comment.fromJson(e)).toList();
  }

  // POST /tracks/{track_id}/comments
  Future<void> addComment({
    required String trackId,
    required String content,
    int? timestampInTrack,
    String? parentCommentId,
  }) async {
    await _dio.post(
      '$_baseUrl/tracks/$trackId/comments',
      data: {
        'content': content,
        if (timestampInTrack != null) 'timestamp_in_track': timestampInTrack,
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      },
    );
  }

  // POST /playlists/  (create playlist)
  Future<Map<String, dynamic>> createPlaylist({
    required String name,
    String? description,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/playlists/',
      data: {'name': name, if (description != null) 'description': description},
    );
    return response.data['data'];
  }

  // GET /playlists/{playlist_id}
  Future<Map<String, dynamic>> getPlaylist({required String playlistId}) async {
    final response = await _dio.get('$_baseUrl/playlists/$playlistId');
    return response.data['data'];
  }

  // PATCH /playlists/{playlist_id}
  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    String? coverPhotoUrl,
  }) async {
    await _dio.patch(
      '$_baseUrl/playlists/$playlistId',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (coverPhotoUrl != null) 'cover_photo_url': coverPhotoUrl,
      },
    );
  }

  // DELETE /playlists/{playlist_id}
  Future<void> deletePlaylist({required String playlistId}) async {
    await _dio.delete('$_baseUrl/playlists/$playlistId');
  }

  // POST /playlists/{playlist_id}/tracks
  Future<void> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    await _dio.post(
      '$_baseUrl/playlists/$playlistId/tracks',
      data: {'track_id': trackId},
    );
  }

  // DELETE /playlists/{playlist_id}/tracks/{track_id}
  Future<void> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    await _dio.delete('$_baseUrl/playlists/$playlistId/tracks/$trackId');
  }
}
