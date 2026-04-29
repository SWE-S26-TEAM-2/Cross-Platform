import 'package:dio/dio.dart';
import '../models/feed_response.dart';

class FeedService {
  final Dio _dio;
  static const String _baseUrl = 'https://streamline-swp.duckdns.org/api';

  FeedService({required Dio dio}) : _dio = dio;

  // GET /feed/following
  Future<FeedResponse> getFollowingFeed({
    int limit = 20,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };
    final response = await _dio.get(
      '$_baseUrl/feed/following',
      queryParameters: queryParams,
    );
    return FeedResponse.fromJson(response.data);
  }

  // GET /feed/discover
  Future<FeedResponse> getDiscoverFeed({int limit = 20, String? cursor}) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };
    final response = await _dio.get(
      '$_baseUrl/feed/discover',
      queryParameters: queryParams,
    );
    return FeedResponse.fromJson(response.data);
  }

  // GET /feed/cached/discover/optimized — cached endpoint with 60s TTL
  Future<CachedFeedResponse> getDiscoverFeedCached({
    int limit = 20,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };
    final response = await _dio.get(
      '$_baseUrl/feed/cached/discover/optimized',
      queryParameters: queryParams,
    );
    return CachedFeedResponse.fromJson(response.data);
  }

  // DELETE /feed/cached/cache/clear
  Future<void> clearFeedCache() async {
    await _dio.delete('$_baseUrl/feed/cached/cache/clear');
  }
}
