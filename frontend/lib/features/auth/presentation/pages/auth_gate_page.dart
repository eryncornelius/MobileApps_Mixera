import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/auth/token_refresh_helper.dart';
import '../../../../core/biometric/app_biometric_auth.dart';
import '../../../../core/biometric/biometric_lock_storage.dart';
import '../../../../core/errors/session_unauthorized_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../profile/data/datasources/profile_remote_datasource.dart';
import '../../../profile/data/models/profile_model.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  String? _error;
  bool _biometricLocked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _routeBySeller(ProfileModel profile) {
    if (profile.isSeller) {
      Navigator.pushReplacementNamed(context, RouteNames.sellerShell);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.mainShell);
    }
  }

  Future<bool> _ensureBiometricUnlocked() async {
    if (!await BiometricLockStorage.isLockEnabled()) return true;
    return AppBiometricAuth.instance.authenticateToUnlock();
  }

  Future<void> _loadProfileAndRoute() async {
    try {
      final profile = await ProfileRemoteDatasource().getProfile();
      if (!mounted) return;
      _routeBySeller(profile);
    } on SessionUnauthorizedException {
      final refreshed = await TokenRefreshHelper.tryRefresh();
      if (!mounted) return;
      if (refreshed) {
        try {
          final profile = await ProfileRemoteDatasource().getProfile();
          if (!mounted) return;
          _routeBySeller(profile);
          return;
        } on SessionUnauthorizedException {
          // fall through: clear session and go to login
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error =
                'Tidak dapat memuat profil setelah memperbarui sesi. Coba lagi.';
          });
          return;
        }
      }
      await TokenStorage.clearTokens();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.login);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Tidak dapat menghubungi server atau profil gagal dimuat. Periksa koneksi lalu coba lagi.';
      });
    }
  }

  Future<void> _checkAuth() async {
    setState(() {
      _error = null;
      _biometricLocked = false;
      _loading = true;
    });

    final hasToken = await TokenStorage.hasToken();

    if (!mounted) return;

    if (!hasToken) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    if (!await _ensureBiometricUnlocked()) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _biometricLocked = true;
      });
      return;
    }

    await _loadProfileAndRoute();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _retryBiometric() async {
    setState(() => _loading = true);
    if (!await _ensureBiometricUnlocked()) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    if (!mounted) return;
    setState(() {
      _biometricLocked = false;
      _loading = true;
    });
    await _loadProfileAndRoute();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _exitBiometricLock() async {
    await TokenStorage.clearTokens();
    await BiometricLockStorage.setLockEnabled(false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_biometricLocked) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fingerprint, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'Buka dengan sidik jari',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Autentikasi dibatalkan atau gagal. Coba lagi atau keluar untuk login dengan akun lain.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _retryBiometric,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Coba lagi'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading ? null : _exitBiometricLock,
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _checkAuth,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
