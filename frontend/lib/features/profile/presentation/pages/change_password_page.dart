import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _hideCurrentPw = true;
  bool _hideNewPw = true;
  bool _hideConfirmPw = true;

  bool get _hasMinLength =>
      Get.find<ProfileController>().newPasswordController.text.length >= 8;
  bool get _hasNumber =>
      Get.find<ProfileController>().newPasswordController.text.contains(RegExp(r'\d'));
  bool get _hasSymbol =>
      Get.find<ProfileController>().newPasswordController.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  bool get _hasMixedCase {
    final pw = Get.find<ProfileController>().newPasswordController.text;
    return pw.contains(RegExp(r'[a-z]')) && pw.contains(RegExp(r'[A-Z]'));
  }

  @override
  Widget build(BuildContext context) {
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Enter your new password below',
                  style: AppTextStyles.description,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Password', style: AppTextStyles.description),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (_, setS) => TextFormField(
                        controller: profileC.currentPasswordController,
                        obscureText: _hideCurrentPw,
                        decoration: InputDecoration(
                          hintText: 'Enter current password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hideCurrentPw
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.secondaryText,
                            ),
                            onPressed: () =>
                                setState(() => _hideCurrentPw = !_hideCurrentPw),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('New Password', style: AppTextStyles.description),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: profileC.newPasswordController,
                      obscureText: _hideNewPw,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hideNewPw
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: () => setState(() => _hideNewPw = !_hideNewPw),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Confirm New Password', style: AppTextStyles.description),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: profileC.confirmNewPasswordController,
                      obscureText: _hideConfirmPw,
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hideConfirmPw
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: () =>
                              setState(() => _hideConfirmPw = !_hideConfirmPw),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _RequirementRow(label: 'Minimum 8 characters', met: _hasMinLength),
                    _RequirementRow(label: 'Include a number', met: _hasNumber),
                    _RequirementRow(label: 'Include a symbol (!@#\$)', met: _hasSymbol),
                    _RequirementRow(
                        label: 'Mix of upper & lowercase letters', met: _hasMixedCase),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Obx(() => ElevatedButton(
                    onPressed: profileC.isChangingPassword.value
                        ? null
                        : () async {
                            final success = await profileC.changePassword();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: profileC.isChangingPassword.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Save Changes'),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
        Text('Change Password', style: AppTextStyles.headline),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool met;

  const _RequirementRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_rounded : Icons.circle_outlined,
            size: 16,
            color: met ? AppColors.success : AppColors.secondaryText,
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }
}
