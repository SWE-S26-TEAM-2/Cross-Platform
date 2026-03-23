import 'package:dio/dio.dart';
import 'package:my_project/models/auth_token.dart';

class AuthService {
  final Dio _dio;
  String baseUrl = 'https://api.soundcloud-clone.com/v1';
  AuthService({required Dio dio}) : _dio = dio; //must set private like this

  Future<void> register(
    ///Endpoint #1 (Module 1)
    String email,
    String password,
    String username,
    String captchaToken,
  ) async {
    await _dio.post(
      '$baseUrl/auth/register',
      data: {
        'email': email,
        'password': password,
        'username': username,
        'captcha_token': captchaToken,
      },
    );
  }

  Future<void> verifyEmail(String token) async {
    ///Endpoint #2 (Module 1)
    await _dio.post('$baseUrl/auth/verify-email', data: {'token': token});
  }

  Future<void> resendVerification(String email) async {
    ///Endpoint #3 (Module 1)
    await _dio.post(
      '$baseUrl/auth/resend-verification',
      data: {'email': email},
    );
  }

  Future<AuthTokens> login(String email, String password) async {
    ///Endpoint #4 (Module 1)
    final result = await _dio.post(
      '$baseUrl/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthTokens.fromJson(result.data);
  }

  Future<AuthTokens> googleLogin(String googleIdToken) async {
    ///Endpoint #5 (Module 1)
    final result = await _dio.post(
      '$baseUrl/auth/google',
      data: {'id_token': googleIdToken},
    );
    return AuthTokens.fromJson(result.data);
  }

  Future<AuthTokens> refreshTokens(String refreshToken) async {
    ///Endpoint #6 (Module 1)
    final result = await _dio.post(
      '$baseUrl/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return AuthTokens.fromJson(result.data);
  }

  Future<void> logout(String accessToken) async {
    ///Endpoint #7 (Module 1)
    await _dio.post(
      '$baseUrl/auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  Future<void> forgotPassword(String email) async {
    ///Endpoint #8 (Module 1)
    await _dio.post('$baseUrl/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    ///Endpoint #9 (Module 1)
    await _dio.post(
      '$baseUrl/auth/reset-password',
      data: {'token': token, 'new_password': newPassword},
    );
  }
}
