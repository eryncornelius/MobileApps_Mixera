import 'package:local_auth/local_auth.dart';

/// Sidik jari / sensor biometrik perangkat (tanpa PIN pola sebagai pengganti).
class AppBiometricAuth {
  AppBiometricAuth._();
  static final AppBiometricAuth instance = AppBiometricAuth._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Perangkat punya biometrik terdaftar (mis. sidik jari).
  Future<bool> canUseBiometricSensor() async {
    if (!await _auth.isDeviceSupported()) return false;
    if (!await _auth.canCheckBiometrics) return false;
    final enrolled = await _auth.getAvailableBiometrics();
    return enrolled.isNotEmpty;
  }

  /// `true` jika pengguna berhasil verifikasi biometrik.
  Future<bool> authenticateToUnlock() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk membuka MIXÉRA',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}
