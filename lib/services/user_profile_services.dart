// services/user_service.dart
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/user.dart';

class UserService {
  final Dio _dio;
  String baseUrl = 'http://68.210.102.76/api';
  UserService({required Dio dio}) : _dio = dio;

  Future<User> getMe(String accessToken) async {
    final res = await _dio.get(
      '$baseUrl/users/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return User.fromJson(res.data['data']);
  }

  Future<User> getUserById(String userId) async {
    final res = await _dio.get('$baseUrl/users/$userId');

    print('GET USER BY ID STATUS: ${res.statusCode}');
    print('GET USER BY ID DATA: ${res.data}');

    return User.fromJson(res.data['data']);
  }

  Future<User> updateMe({
    required String accessToken,
    String? displayName,
    String? bio,
    String? location,
  }) async {
    final res = await _dio.patch(
      '$baseUrl/users/me',
      data: {
        if (displayName != null) 'display_name': displayName,
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    print('PATCH /users/me STATUS: ${res.statusCode}');
    print('PATCH /users/me DATA: ${res.data}');

    return User.fromJson(res.data['data']);
  }

  Future<bool> updatePrivacy({
    required String accessToken,
    required bool isPrivate,
  }) async {
    final res = await _dio.patch(
      '$baseUrl/users/me/privacy',
      data: {'is_private': isPrivate},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    print('PATCH /users/me/privacy STATUS: ${res.statusCode}');
    print('PATCH /users/me/privacy DATA: ${res.data}');

    return res.data['data']['is_private'] as bool;
  }

  Future<String?> uploadAvatar({
  required String accessToken,
  required String filePath,
}) async {
  final fileName = filePath.split('/').last;

  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      filePath,
      filename: fileName,
    ),
  });

  final res = await _dio.put(
    '$baseUrl/users/me/avatar',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

  print('PUT /users/me/avatar STATUS: ${res.statusCode}');
  print('PUT /users/me/avatar DATA: ${res.data}');

  return res.data['data']?['profile_picture']?.toString();
}

Future<String?> uploadCover({
  required String accessToken,
  required String filePath,
}) async {
  final fileName = filePath.split('/').last;

  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      filePath,
      filename: fileName,
    ),
  });

  final res = await _dio.put(
    '$baseUrl/users/me/cover',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

  print('PUT /users/me/cover STATUS: ${res.statusCode}');
  print('PUT /users/me/cover DATA: ${res.data}');

  return res.data['data']?['cover_photo']?.toString();
}
}
