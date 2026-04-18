import 'package:dio/dio.dart';
import '../models/track.dart';

class TracksService {
  final Dio _dio;
  String baseUrl = 'http://68.210.102.76/api';
  TracksService({required Dio dio}) : _dio = dio; //must set private like this

  // POST /tracks/ — multipart/form-data
  Future<Track> createTrack({
    required String title,
    required String description,
    required String filePath,
    String? genre,
    String? tags,
    String? releaseDate,
    String visibility = 'public',
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'visibility': visibility,
      if (genre != null) 'genre': genre,
      if (tags != null) 'tags': tags,
      if (releaseDate != null) 'release_date': releaseDate,
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post('$baseUrl/tracks/', data: formData);
    return Track.fromJson(response.data['data']);
  }

  // GET /tracks/{track_id}
  Future<Track> getTrack({required String trackId}) async {
    final response = await _dio.get('$baseUrl/tracks/$trackId');
    return Track.fromJson(response.data['data']);
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
    final response = await _dio.put(
      '$baseUrl/tracks/$trackId',
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
    return Track.fromJson(response.data['data']);
  }

  // DELETE /tracks/{track_id}
  Future<void> deleteTrack({required String trackId}) async {
    await _dio.delete('$baseUrl/tracks/$trackId');
  }

  // GET /tracks/{track_id}/waveform
  Future<List<double>> getTrackWaveform({required String trackId}) async {
    final response = await _dio.get('$baseUrl/tracks/$trackId/waveform');
    final List data = response.data['data'];
    return data.map((e) => (e as num).toDouble()).toList();
  }

  // GET /tracks/{track_id}/stream
  Future<String> getTrackStreamUrl({required String trackId}) async {
    final response = await _dio.get('$baseUrl/tracks/$trackId/stream');
    return response.data['data']['stream_url'] as String;
  }

  // POST /tracks/{track_id}/plays
  Future<void> recordPlay({
    required String trackId,
    int? durationListenedSeconds,
  }) async {
    await _dio.post(
      '$baseUrl/tracks/$trackId/plays',
      data: durationListenedSeconds != null
          ? {'duration_listened_seconds': durationListenedSeconds}
          : null,
    );
  }

  // GET /tracks/{track_id}/playback
  Future<Map<String, dynamic>> getTrackPlayback({
    required String trackId,
  }) async {
    final response = await _dio.get('$baseUrl/tracks/$trackId/playback');
    return response.data['data'] as Map<String, dynamic>;
  }
}
