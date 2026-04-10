import 'package:dio/dio.dart';
import 'package:my_project/models/auth_token.dart';

class AuthService {
  final Dio _dio;
  String baseUrl = 'http://68.210.102.76/api';

  AuthService({required Dio dio}) : _dio = dio;

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    await _dio.post(
      '$baseUrl/auth/register',
      data: {'email': email, 'password': password, 'display_name': displayName},
    );
  }

  Future<void> verifyEmail(String token) async {
    await _dio.post('$baseUrl/auth/verify-email', data: {'token': token});
  }

  Future<void> resendVerification(String email) async {
    await _dio.post(
      '$baseUrl/auth/resend-verification',
      data: {'email': email},
    );
  }

  Future<AuthTokens> login(String email, String password) async {
    final result = await _dio.post(
      '$baseUrl/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthTokens.fromJson(result.data);
  }

  Future<AuthTokens> googleLogin(String googleIdToken) async {
    final result = await _dio.post(
      '$baseUrl/auth/google',
      data: {'id_token': googleIdToken},
    );
    return AuthTokens.fromJson(result.data);
  }

  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final result = await _dio.post(
      '$baseUrl/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return AuthTokens.fromJson(result.data);
  }

  Future<void> logout(String accessToken) async {
    await _dio.post(
      '$baseUrl/auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('$baseUrl/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post(
      '$baseUrl/auth/reset-password',
      data: {'token': token, 'new_password': newPassword},
    );
  }
}
