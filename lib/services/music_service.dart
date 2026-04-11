import 'package:dio/dio.dart';

class MusicService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://api.soundcloud-clone.com/v1'),
  );

  Future<List<dynamic>> getTracks() async {
    final res = await _dio.get('/tracks');
    return res.data;
  }

  Future<List<dynamic>> getFeed() async {
    final res = await _dio.get('/feed');
    return res.data;
  }

  Future<List<dynamic>> getVibes() async {
    final res = await _dio.get('/vibes');
    return res.data;
  }

  Future<List<dynamic>> searchTracks(String query) async {
    final res = await _dio.get("/search", queryParameters: {"q": query});
    return res.data;
  }
}
