import 'package:dio/dio.dart';
import 'package:my_project/models/auth_token.dart';

class AuthService {
  final Dio _dio;
  final String baseUrl = 'https://streamline-swp.duckdns.org/api';

  AuthService({required Dio dio}) : _dio = dio;

  // POST /auth/register
  // API requires: email, username, password, display_name
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
    String accountType = 'listener',
  }) async {
    await _dio.post(
      '$baseUrl/auth/register',
      data: {'email': email, 'password': password, 'display_name': displayName},
    );
  }

  // POST /auth/verify-email
  Future<void> verifyEmail(String token) async {
    await _dio.post('$baseUrl/auth/verify-email', data: {'token': token});
  }

  // POST /auth/resend-verification
  Future<void> resendVerification(String email) async {
    await _dio.post(
      '$baseUrl/auth/resend-verification',
      data: {'email': email},
    );
  }

  Future<AuthTokens> login(String email, String password) async {
    try {
      final result = await _dio.post(
        '$baseUrl/auth/login',
        data: {'identifier': email, 'password': password},
      );

      print('LOGIN STATUS: ${result.statusCode}');
      print('LOGIN DATA: ${result.data}');

      return AuthTokens.fromJson(result.data);
    } on DioException catch (e) {
      print('LOGIN ERROR STATUS: ${e.response?.statusCode}');
      print('LOGIN ERROR DATA: ${e.response?.data}');
      rethrow;
    }
  }

  // POST /auth/google
  Future<AuthTokens> googleLogin(String googleIdToken) async {
    try {
      final result = await _dio.post(
        '$baseUrl/auth/google',
        data: {'google_token': googleIdToken},
      );

      print('GOOGLE LOGIN STATUS: ${result.statusCode}');
      print('GOOGLE LOGIN DATA: ${result.data}');

      return AuthTokens.fromJson(result.data);
    } on DioException catch (e) {
      print('GOOGLE LOGIN ERROR STATUS: ${e.response?.statusCode}');
      print('GOOGLE LOGIN ERROR DATA: ${e.response?.data}');
      rethrow;
    }
  }

  // POST /auth/facebook
  Future<AuthTokens> facebookLogin(String facebookToken) async {
    try {
      final result = await _dio.post(
        '$baseUrl/auth/facebook',
        data: {'facebook_token': facebookToken},
      );

      print('FACEBOOK LOGIN STATUS: ${result.statusCode}');
      print('FACEBOOK LOGIN DATA: ${result.data}');

      return AuthTokens.fromJson(result.data);
    } on DioException catch (e) {
      print('FACEBOOK LOGIN ERROR STATUS: ${e.response?.statusCode}');
      print('FACEBOOK LOGIN ERROR DATA: ${e.response?.data}');
      rethrow;
    }
  }

  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final result = await _dio.post(
      '$baseUrl/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    return AuthTokens.fromJson(result.data);
  }

  // POST /auth/logout
  // API requires: refresh_token in body + Bearer token in header
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _dio.post(
      '$baseUrl/auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // POST /auth/forgot-password
  Future<void> forgotPassword(String email) async {
    await _dio.post('$baseUrl/auth/forgot-password', data: {'email': email});
  }

  // POST /auth/reset-password
  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post(
      '$baseUrl/auth/reset-password',
      data: {'token': token, 'new_password': newPassword},
    );
  }
}
