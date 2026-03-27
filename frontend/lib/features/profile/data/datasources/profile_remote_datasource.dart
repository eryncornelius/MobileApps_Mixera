import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../models/profile_model.dart';

class ProfileRemoteDatasource {
  ProfileRemoteDatasource()
    : dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  final Dio dio;

  static const String _baseUrl = 'http://127.0.0.1:8000/api/users';

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

  Future<Options> _authorizedOptions() async {
    final token = await TokenStorage.getAccessToken();

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get(
        '/me/',
        options: await _authorizedOptions(),
      );

      return ProfileModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ProfileModel> updateProfile({
    required String username,
    required String? phoneNumber,
  }) async {
    try {
      final response = await dio.put(
        '/profile/',
        data: {'username': username, 'phone_number': phoneNumber},
        options: await _authorizedOptions(),
      );

      return ProfileModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
