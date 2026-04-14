import '../storage/secure_storage_service.dart';

/// Whether the user turned on "buka app dengan sidik jari" (device biometrics only).
class BiometricLockStorage {
  static const String _key = 'mixera_app_biometric_lock_v1';

  static Future<bool> isLockEnabled() async {
    final v = await SecureStorageService.read(_key);
    return v == '1';
  }

  static Future<void> setLockEnabled(bool enabled) async {
    if (enabled) {
      await SecureStorageService.write(_key, '1');
    } else {
      await SecureStorageService.delete(_key);
    }
  }
}
