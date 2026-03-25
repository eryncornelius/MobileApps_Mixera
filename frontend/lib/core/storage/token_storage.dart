import 'secure_storage_service.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await SecureStorageService.write(_accessTokenKey, accessToken);
    await SecureStorageService.write(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return SecureStorageService.read(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return SecureStorageService.read(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await SecureStorageService.delete(_accessTokenKey);
    await SecureStorageService.delete(_refreshTokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
