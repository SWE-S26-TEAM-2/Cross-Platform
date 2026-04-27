import 'package:dio/dio.dart';
import '../models/track.dart';

class MusicService {
  final Dio _dio;
  static const String _baseUrl = 'https://streamline-swp.duckdns.org/api';

  MusicService({required Dio dio}) : _dio = dio;

  // GET /search/tracks?keyword=query
  Future<List<Track>> searchTracks(String query) async {
    final res = await _dio.get(
      '$_baseUrl/search/tracks',
      queryParameters: {'keyword': query},
    );
    final List tracks = res.data['data'] ?? [];
    return tracks.map<Track>((json) => Track.fromJson(json)).toList();
  }

  // GET /tracks/{track_id}
  Future<Track> getTrack({required String trackId}) async {
    final res = await _dio.get('$_baseUrl/tracks/$trackId');
    return Track.fromJson(res.data['data']);
  }

  // POST /tracks/ (multipart/form-data)
  // Required: title, description, file
  // Optional: genre, tags (comma-separated string), release_date, visibility, cover_image
  Future<Track> createTrack({
    required String title,
    required String description,
    required String filePath,
    String? genre,
    String? tags,
    String? releaseDate,
    String visibility = 'public',
    String? coverImagePath,
  }) async {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'visibility': visibility,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    };
    if (genre != null) map['genre'] = genre;
    if (tags != null) map['tags'] = tags;
    if (releaseDate != null) map['release_date'] = releaseDate;
    if (coverImagePath != null) {
      map['cover_image'] = await MultipartFile.fromFile(
        coverImagePath,
        filename: coverImagePath.split('/').last,
      );
    }
    final res = await _dio.post(
      '$_baseUrl/tracks/',
      data: FormData.fromMap(map),
    );
    return Track.fromJson(res.data['data']);
  }

  // PUT /tracks/{track_id}
  Future<Track> updateTrack({
    required String trackId,
    String? title,
    String? description,
    String? genre,
    List<String>? tags,
    String? releaseDate,
    String? fileUrl,
    String? visibility,
  }) async {
    final res = await _dio.put(
      '$_baseUrl/tracks/$trackId',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (genre != null) 'genre': genre,
        if (tags != null) 'tags': tags,
        if (releaseDate != null) 'release_date': releaseDate,
        if (fileUrl != null) 'file_url': fileUrl,
        if (visibility != null) 'visibility': visibility,
      },
    );
    return Track.fromJson(res.data['data']);
  }

  // DELETE /tracks/{track_id}
  Future<void> deleteTrack({required String trackId}) async {
    await _dio.delete('$_baseUrl/tracks/$trackId');
  }

  // GET /tracks/{track_id}/stream
  Future<Map<String, dynamic>> getTrackStream({required String trackId}) async {
    final res = await _dio.get('$_baseUrl/tracks/$trackId/stream');
    return res.data['data'];
  }

  // GET /tracks/{track_id}/audio (actual audio stream)
  Future<String> getTrackAudioUrl({required String trackId}) async {
    return '$_baseUrl/tracks/$trackId/audio';
  }

  // GET /tracks/{track_id}/waveform
  Future<Map<String, dynamic>> getTrackWaveform({
    required String trackId,
  }) async {
    final res = await _dio.get('$_baseUrl/tracks/$trackId/waveform');
    return res.data['data'];
  }

  // POST /tracks/{track_id}/plays
  Future<void> recordPlay({
    required String trackId,
    int? durationListenedSeconds,
  }) async {
    await _dio.post(
      '$_baseUrl/tracks/$trackId/plays',
      data: durationListenedSeconds != null
          ? {'duration_listened_seconds': durationListenedSeconds}
          : null,
    );
  }

  // GET /tracks/{track_id}/playback
  Future<Map<String, dynamic>> getTrackPlayback({
    required String trackId,
  }) async {
    final res = await _dio.get('$_baseUrl/tracks/$trackId/playback');
    return res.data['data'];
  }

  // GET /search/users?keyword=query
  Future<List<dynamic>> searchUsers(String query) async {
    final res = await _dio.get(
      '$_baseUrl/search/users',
      queryParameters: {'keyword': query},
    );
    return res.data['data'] ?? [];
  }

  // GET /search/playlists?keyword=query
  Future<List<dynamic>> searchPlaylists(String query) async {
    final res = await _dio.get(
      '$_baseUrl/search/playlists',
      queryParameters: {'keyword': query},
    );
    return res.data['data'] ?? [];
  }
}
