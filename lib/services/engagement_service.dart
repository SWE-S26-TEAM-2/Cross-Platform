import 'package:dio/dio.dart';
import '../models/comment.dart';

class EngagementService {
  final Dio _dio;
  String baseUrl = 'http://68.210.102.76/api';
  EngagementService({required Dio dio})
    : _dio = dio; //must set private like this

  // POST /likes/tracks/{track_id}
  Future<void> likeTrack({required String trackId}) async {
    await _dio.post('$baseUrl/likes/tracks/$trackId');
  }

  // DELETE /likes/tracks/{track_id}
  Future<void> unlikeTrack({required String trackId}) async {
    await _dio.delete('$baseUrl/likes/tracks/$trackId');
  }

  // POST /reposts/tracks/{track_id}
  Future<void> repostTrack({required String trackId}) async {
    await _dio.post('$baseUrl/reposts/tracks/$trackId');
  }

  // DELETE /reposts/tracks/{track_id}
  Future<void> removeRepost({required String trackId}) async {
    await _dio.delete('$baseUrl/reposts/tracks/$trackId');
  }

  // GET /tracks/{track_id}/comments
  Future<List<Comment>> getComments({
    required String trackId,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '$baseUrl/tracks/$trackId/comments',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final List data = response.data['data'];
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
      '$baseUrl/tracks/$trackId/comments',
      data: {
        'content': content,
        if (timestampInTrack != null) 'timestamp_in_track': timestampInTrack,
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      },
    );
  }
}
