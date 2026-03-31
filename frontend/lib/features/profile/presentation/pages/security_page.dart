import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/security_option_tile.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = false;

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
              SecurityOptionTile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                description: 'Keep your account secure by changing your password',
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.changePassword),
                    child: const Text('Change Password'),
                  ),
                  const SizedBox(height: 12),
                  _RequirementRow(label: 'Minimum 8 characters'),
                  _RequirementRow(label: 'Include a number'),
                  _RequirementRow(label: 'Include a symbol (!@#\$)'),
                  _RequirementRow(label: 'Mix of upper & lowercase letters'),
                ],
              ),
              const SizedBox(height: 16),
              // Biometric card
              SecurityOptionTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Authentication',
                description: 'Use face ID or Fingerprint to log in faster and secure your account',
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
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
