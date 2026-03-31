import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../models/profile_model.dart';
import '../models/address_model.dart';
import '../models/notification_settings_model.dart';

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
  Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
  }) async {
    try {
      await dio.post(
        '/change-password/',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: await _authorizedOptions(),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
  Future<List<AddressModel>> getAddresses() async {
  try {
    final response = await dio.get(
      '/addresses/',
      options: await _authorizedOptions(),
    );

    final data = List<Map<String, dynamic>>.from(response.data);
    return data.map(AddressModel.fromJson).toList();
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}

Future<AddressModel> createAddress({
  required String label,
  required String recipientName,
  required String phoneNumber,
  required String streetAddress,
  required String city,
  required String state,
  required String postalCode,
  required bool isPrimary,
}) async {
  try {
    final response = await dio.post(
      '/addresses/',
      data: {
        'label': label,
        'recipient_name': recipientName,
        'phone_number': phoneNumber,
        'street_address': streetAddress,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'is_primary': isPrimary,
      },
      options: await _authorizedOptions(),
    );

    return AddressModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}

Future<AddressModel> updateAddress({
  required int id,
  required String label,
  required String recipientName,
  required String phoneNumber,
  required String streetAddress,
  required String city,
  required String state,
  required String postalCode,
  required bool isPrimary,
}) async {
  try {
    final response = await dio.put(
      '/addresses/$id/',
      data: {
        'label': label,
        'recipient_name': recipientName,
        'phone_number': phoneNumber,
        'street_address': streetAddress,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'is_primary': isPrimary,
      },
      options: await _authorizedOptions(),
    );

    return AddressModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}

Future<void> deleteAddress(int id) async {
  try {
    await dio.delete(
      '/addresses/$id/',
      options: await _authorizedOptions(),
    );
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}

Future<NotificationSettingsModel> getNotificationSettings() async {
  try {
    final response = await dio.get(
      '/notification-settings/',
      options: await _authorizedOptions(),
    );
    return NotificationSettingsModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}

Future<NotificationSettingsModel> updateNotificationSettings({
  required bool orderUpdates,
  required bool promotions,
  required bool securityAlerts,
  required bool dailyReminders,
}) async {
  try {
    final response = await dio.put(
      '/notification-settings/',
      data: {
        'order_updates': orderUpdates,
        'promotions': promotions,
        'security_alerts': securityAlerts,
        'daily_reminders': dailyReminders,
      },
      options: await _authorizedOptions(),
    );
    return NotificationSettingsModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}
}
