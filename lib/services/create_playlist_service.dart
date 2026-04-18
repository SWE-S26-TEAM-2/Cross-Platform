import 'package:dio/dio.dart';
import '../models/playlist.dart';

class CreatePlaylistService {
  final Dio _dio;
  final String baseUrl = 'http://68.210.102.76/api';

  CreatePlaylistService({required Dio dio}) : _dio = dio;

  Future<Playlist> createPlaylist({
    required String accessToken,
    required String name,
    String? description,
  }) async {
    final res = await _dio.post(
      '$baseUrl/playlists/',
      data: {
        'name': name,
        'description': description ?? '',
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    print('CREATE PLAYLIST STATUS: ${res.statusCode}');
    print('CREATE PLAYLIST DATA: ${res.data}');

    final data = res.data['data'] as Map<String, dynamic>? ?? {};

    return Playlist.fromJson(data);
  }
}