import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';

/// Uses stored refresh token to obtain a new access token from the backend.
class TokenRefreshHelper {
  TokenRefreshHelper._();

  static final _auth = AuthRemoteDatasource();

  /// Returns true if new tokens were saved.
  static Future<bool> tryRefresh() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final data = await _auth.refreshTokens(refresh: refresh);
      final access = data['access'] as String?;
      if (access == null || access.isEmpty) return false;
      final newRefresh = data['refresh'] as String? ?? refresh;
      await TokenStorage.saveTokens(
        accessToken: access,
        refreshToken: newRefresh,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
