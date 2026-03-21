// services/user_service.dart
import 'package:dio/dio.dart';
import '../models/user.dart';

class UserService {
  final Dio _dio;
  String baseUrl = 'https://api.soundcloud-clone.com/v1';
  UserService({required Dio dio}) : _dio = dio;

  Future<User> getMe(String accessToken) async {
    final res = await _dio.get(
      '$baseUrl/users/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return User.fromJson(res.data);
  }
}
