import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiBaseUrl.module('users'),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  final Dio dio;

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;

      if (data is Map) {
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }

        if (data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            return firstValue.first.toString();
          }
          return firstValue.toString();
        }
      }
    }

    return 'Gagal terhubung ke server. Periksa koneksi Anda.';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login/',
        data: {'email': email, 'password': password},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String username,
    String phone,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/register/',
        data: {
          'email': email,
          'username': username,
          'phone_number': phone,
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    try {
      final response = await dio.post(
        '/verify-otp/',
        data: {'email': email, 'code': code},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        '/forgot-password/',
        data: {'email': email},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post(
        '/reset-password/',
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await dio.post('/google/', data: {'id_token': idToken});

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Exchange refresh JWT for a new access token (SimpleJWT).
  Future<Map<String, dynamic>> refreshTokens({required String refresh}) async {
    try {
      final response = await dio.post(
        '/login/refresh/',
        data: {'refresh': refresh},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> loginWithFacebook(String accessToken) async {
    try {
      final response = await dio.post(
        '/facebook/',
        data: {'access_token': accessToken},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
