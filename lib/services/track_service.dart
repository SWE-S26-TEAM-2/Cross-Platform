// services/tracks_service.dart

import 'package:dio/dio.dart';
import '../models/track.dart';

class TracksService {
  final Dio _dio;
  static const String _base = 'https://streamline-swp.duckdns.org/api';

  TracksService({required Dio dio}) : _dio = dio;

  // ── GET /tracks/{track_id} ────────────────────────────────────────────────

  Future<Track> getTrack({required String trackId}) async {
    final res = await _dio.get('$_base/tracks/$trackId');
    return Track.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── POST /tracks/ (multipart/form-data) ──────────────────────────────────

  Future<Track> createTrack({
    required String accessToken,
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

    if (genre != null && genre.trim().isNotEmpty) {
      map['genre'] = genre.trim();
    }

    if (tags != null && tags.trim().isNotEmpty) {
      map['tags'] = tags.trim();
    }

    if (releaseDate != null && releaseDate.trim().isNotEmpty) {
      map['release_date'] = releaseDate.trim();
    }

    if (coverImagePath != null && coverImagePath.trim().isNotEmpty) {
      map['cover_image'] = await MultipartFile.fromFile(
        coverImagePath,
        filename: coverImagePath.split('/').last,
      );
    }

    final res = await _dio.post(
      '$_base/tracks/',
      data: FormData.fromMap(map),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return Track.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── PUT /tracks/{track_id} ────────────────────────────────────────────────

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
      '$_base/tracks/$trackId',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (genre != null) 'genre': genre,
        if (tags != null) 'tags': tags.join(','), // ✅ fixed here
        if (releaseDate != null) 'release_date': releaseDate,
        if (fileUrl != null) 'file_url': fileUrl,
        if (visibility != null) 'visibility': visibility,
      },
    );

    return Track.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── DELETE /tracks/{track_id} ─────────────────────────────────────────────

  Future<void> deleteTrack({required String trackId}) async {
    await _dio.delete('$_base/tracks/$trackId');
  }

  // ── GET /tracks/{track_id}/stream ─────────────────────────────────────────
  // Returns StreamData: { track_id, stream_url, expires_in, content_type,
  //                       play_count, processing_status }

  Future<Map<String, dynamic>> getTrackStream({required String trackId}) async {
    final res = await _dio.get('$_base/tracks/$trackId/stream');
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── GET /tracks/{track_id}/audio ──────────────────────────────────────────
  // Returns the raw audio bytes (streamed). Use this URL directly in a player.

  String getTrackAudioUrl({required String trackId}) =>
      '$_base/tracks/$trackId/audio';

  // ── GET /tracks/{track_id}/waveform ──────────────────────────────────────
  // Returns WaveformData: { track_id, duration_seconds, sample_count, peaks[] }

  Future<Map<String, dynamic>> getTrackWaveform({
    required String trackId,
  }) async {
    final res = await _dio.get('$_base/tracks/$trackId/waveform');
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── GET /tracks/{track_id}/playback ──────────────────────────────────────
  // Returns PlaybackData (includes embedded waveform, stream_url, etc.)

  Future<Map<String, dynamic>> getTrackPlayback({
    required String trackId,
  }) async {
    final res = await _dio.get('$_base/tracks/$trackId/playback');
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── POST /tracks/{track_id}/plays ─────────────────────────────────────────

  Future<void> recordPlay({
    required String trackId,
    int? durationListenedSeconds,
  }) async {
    await _dio.post(
      '$_base/tracks/$trackId/plays',
      data: durationListenedSeconds != null
          ? {'duration_listened_seconds': durationListenedSeconds}
          : null,
    );
  }

  // ── GET /feed/following ───────────────────────────────────────────────────
  // Returns FeedData: { items: FeedTrackItem[], next_cursor, has_more }

  Future<Map<String, dynamic>> getFollowingFeed({
    int limit = 20,
    String? cursor,
  }) async {
    final res = await _dio.get(
      '$_base/feed/following',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── GET /feed/discover ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDiscoverFeed({
    int limit = 20,
    String? cursor,
  }) async {
    final res = await _dio.get(
      '$_base/feed/discover',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── GET /users/{username}/tracks ──────────────────────────────────────────

  Future<List<Track>> getUserTracks({required String username}) async {
    final res = await _dio.get('$_base/users/$username/tracks');
    final data = res.data['data'] as Map<String, dynamic>;
    final List tracks = data['tracks'] as List? ?? [];
    return tracks
        .map((e) => Track.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET /users/{username}/liked-tracks ────────────────────────────────────

  Future<List<Track>> getUserLikedTracks({required String username}) async {
    final res = await _dio.get('$_base/users/$username/liked-tracks');
    final data = res.data['data'] as Map<String, dynamic>;
    final List tracks = data['tracks'] as List? ?? [];
    return tracks
        .map((e) => Track.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET /search/tracks?keyword= ──────────────────────────────────────────

  Future<List<Track>> searchTracks({required String keyword}) async {
    final res = await _dio.get(
      '$_base/search/tracks',
      queryParameters: {'keyword': keyword},
    );
    final List tracks = (res.data['data']['tracks'] as List?) ?? [];
    return tracks
        .map((e) => Track.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
