import 'package:dio/dio.dart';

import '../../../../core/errors/session_unauthorized_exception.dart';
import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/profile_model.dart';
import '../models/address_model.dart';
import '../models/address_suggestion_model.dart';
import '../models/notification_settings_model.dart';

class ProfileRemoteDatasource {
  ProfileRemoteDatasource()
      : dio = createAuthenticatedDio(baseUrl: ApiBaseUrl.module('users')),
        _geoDio = Dio(
          BaseOptions(
            baseUrl: 'https://nominatim.openstreetmap.org',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: const {
              // Nominatim requires an identifying user agent.
              'User-Agent': 'MixeraApp/1.0 (address-autocomplete)',
              'Accept': 'application/json',
            },
          ),
        );

  final Dio dio;
  final Dio _geoDio;

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

  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get('/me/');

      return ProfileModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const SessionUnauthorizedException();
      }
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
        data: {
          'username': username,
          'phone_number': phoneNumber,
        },
      );

      return ProfileModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ProfileModel> requestEmailChange(String newEmail) async {
    try {
      final response = await dio.post(
        '/profile/email-change/request/',
        data: {'new_email': newEmail.trim()},
      );
      return ProfileModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ProfileModel> confirmEmailChange(String code) async {
    try {
      final response = await dio.post(
        '/profile/email-change/confirm/',
        data: {'code': code.trim()},
      );
      return ProfileModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ProfileModel> cancelEmailChange() async {
    try {
      final response = await dio.post('/profile/email-change/cancel/');
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
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
  Future<List<AddressModel>> getAddresses() async {
  try {
    final response = await dio.get('/addresses/');

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
    );
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}

Future<NotificationSettingsModel> getNotificationSettings() async {
  try {
    final response = await dio.get(
      '/notification-settings/',
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
    );
    return NotificationSettingsModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  } on DioException catch (e) {
    throw Exception(_handleError(e));
  }
}

Future<List<AddressSuggestionModel>> searchAddressSuggestions(String query) async {
  final q = query.trim();
  if (q.length < 3) return [];
  try {
    final response = await _geoDio.get(
      '/search',
      queryParameters: {
        'format': 'jsonv2',
        'addressdetails': 1,
        'countrycodes': 'id',
        'limit': 5,
        'q': q,
      },
    );
    final raw = response.data as List? ?? const [];
    return raw
        .map((e) => AddressSuggestionModel.fromNominatim(Map<String, dynamic>.from(e as Map)))
        .where((s) => s.streetAddress.isNotEmpty || s.fullAddress.isNotEmpty)
        .toList();
  } on DioException {
    // Keep silent for autocomplete; user can still fill manually.
    return [];
  }
}
}
