import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/playlist.dart';

class PlaylistService {
  final Dio _dio;
  final String baseUrl = apiBaseUrl;

  PlaylistService({required Dio dio}) : _dio = dio;

  Future<Playlist> getPlaylistById(String playlistId) async {
    final res = await _dio.get('$baseUrl/playlists/$playlistId');

    print('GET PLAYLIST STATUS: ${res.statusCode}');
    print('GET PLAYLIST DATA: ${res.data}');

    return Playlist.fromJson(res.data['data']);
  }
}
