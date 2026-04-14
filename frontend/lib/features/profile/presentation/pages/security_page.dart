import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/biometric/app_biometric_auth.dart';
import '../../../../core/biometric/biometric_lock_storage.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/security_option_tile.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = false;
  bool _biometricBusy = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPref();
  }

  Future<void> _loadBiometricPref() async {
    final v = await BiometricLockStorage.isLockEnabled();
    if (mounted) setState(() => _biometricEnabled = v);
  }

  Future<void> _onBiometricToggle(bool wantOn) async {
    if (_biometricBusy) return;
    setState(() => _biometricBusy = true);
    try {
      if (wantOn) {
        final can = await AppBiometricAuth.instance.canUseBiometricSensor();
        if (!mounted) return;
        if (!can) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Sidik jari tidak tersedia. Pastikan perangkat mendukung dan sidik jari sudah didaftarkan di pengaturan sistem.',
              ),
            ),
          );
          return;
        }
        final ok = await AppBiometricAuth.instance.authenticateToUnlock();
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autentikasi dibatalkan atau gagal.'),
            ),
          );
          return;
        }
        await BiometricLockStorage.setLockEnabled(true);
        if (!mounted) return;
        setState(() => _biometricEnabled = true);
      } else {
        await BiometricLockStorage.setLockEnabled(false);
        if (!mounted) return;
        setState(() => _biometricEnabled = false);
      }
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 28),
              // Change Password card
              Obx(() {
                final provider =
                    Get.find<ProfileController>().profile.value?.authProvider ?? 'email';
                final isSocial = provider == 'google' || provider == 'facebook';
                return SecurityOptionTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  description: isSocial
                      ? 'Password management is not available for ${provider[0].toUpperCase()}${provider.substring(1)} accounts'
                      : 'Keep your account secure by changing your password',
                  children: isSocial
                      ? [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 16, color: AppColors.secondaryText),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You signed in with ${provider[0].toUpperCase()}${provider.substring(1)}. Password changes are managed through your ${provider[0].toUpperCase()}${provider.substring(1)} account.',
                                  style: AppTextStyles.small,
                                ),
                              ),
                            ],
                          ),
                        ]
                      : [
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, RouteNames.changePassword),
                            child: const Text('Change Password'),
                          ),
                          const SizedBox(height: 12),
                          _RequirementRow(label: 'Minimum 8 characters'),
                          _RequirementRow(label: 'Include a number'),
                          _RequirementRow(label: 'Include a symbol (!@#\$)'),
                          _RequirementRow(label: 'Mix of upper & lowercase letters'),
                        ],
                );
              }),
              const SizedBox(height: 16),
              // Sidik jari: kunci pembuka app (token sudah ada), bukan login server.
              SecurityOptionTile(
                icon: Icons.fingerprint_rounded,
                title: 'Sidik jari',
                description:
                    'Saat membuka aplikasi, Anda diminta sidik jari dulu. Hanya sensor biometrik (tanpa PIN pola sebagai pengganti).',
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: _biometricBusy ? null : _onBiometricToggle,
                  activeThumbColor: AppColors.blushPink,
                  activeTrackColor: AppColors.roseMist,
                  inactiveThumbColor: AppColors.secondaryText,
                  inactiveTrackColor: AppColors.border,
                ),
              ),
              const SizedBox(height: 16),
              // Log out all devices card
              SecurityOptionTile(
                icon: Icons.devices_rounded,
                title: 'Log Out Of All Devices',
                description: 'Log out of your account from all connected devices',
                children: [
                  GestureDetector(
                    onTap: () => _showLogoutAllDialog(context),
                    child: Text(
                      'Log out from all devices',
                      style: AppTextStyles.description.copyWith(
                        color: AppColors.blushPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutAllDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log out of all devices?', style: AppTextStyles.section),
        content: Text(
          'Are you sure you want to log out of your account on all connected devices?\n\nYou will need to log back in to continue using your account',
          style: AppTextStyles.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.description.copyWith(color: AppColors.blushPink),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<AuthController>().logout(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left_rounded,
                  size: 28, color: AppColors.primaryText),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'MIXÉRA',
                  style: AppTextStyles.logo
                      .copyWith(color: AppColors.blushPink, letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
        const SizedBox(height: 16),
        Text('Security', style: AppTextStyles.headline),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  const _RequirementRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }
}
