import 'package:dio/dio.dart';
import 'package:my_project/models/auth_token.dart';

class AuthService {
  final Dio _dio;
  static const String _baseUrl = 'https://streamline-swp.duckdns.org/api';

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
      '$_baseUrl/auth/register',
      data: {
        'email': email,
        'username': username,
        'password': password,
        'display_name': displayName,
        'account_type': accountType,
      },
    );
  }

  // POST /auth/verify-email
  Future<void> verifyEmail(String token) async {
    await _dio.post('$_baseUrl/auth/verify-email', data: {'token': token});
  }

  // POST /auth/resend-verification
  Future<void> resendVerification(String email) async {
    await _dio.post(
      '$_baseUrl/auth/resend-verification',
      data: {'email': email},
    );
  }

  // POST /auth/login
  // API requires: identifier (not email), password
  Future<AuthTokens> login(String identifier, String password) async {
    final result = await _dio.post(
      '$_baseUrl/auth/login',
      data: {'identifier': identifier, 'password': password},
    );
    return AuthTokens.fromJson(result.data);
  }

  // POST /auth/google
  Future<AuthTokens> googleLogin(String googleIdToken) async {
    final result = await _dio.post(
      '$_baseUrl/auth/google',
      data: {'google_token': googleIdToken},
    );
    return AuthTokens.fromJson(result.data);
  }

  // POST /auth/facebook
  Future<AuthTokens> facebookLogin(String facebookToken) async {
    final result = await _dio.post(
      '$_baseUrl/auth/facebook',
      data: {'facebook_token': facebookToken},
    );
    return AuthTokens.fromJson(result.data);
  }

  // POST /auth/refresh
  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final result = await _dio.post(
      '$_baseUrl/auth/refresh',
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
      '$_baseUrl/auth/logout',
      data: {'refresh_token': refreshToken},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // POST /auth/forgot-password
  Future<void> forgotPassword(String email) async {
    await _dio.post('$_baseUrl/auth/forgot-password', data: {'email': email});
  }

  // POST /auth/reset-password
  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post(
      '$_baseUrl/auth/reset-password',
      data: {'token': token, 'new_password': newPassword},
    );
  }
}
