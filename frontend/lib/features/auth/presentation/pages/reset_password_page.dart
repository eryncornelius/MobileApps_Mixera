import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/inputs/otp_input_field.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool get _hasMinLength =>
      Get.find<AuthController>().newPasswordController.text.length >= 8;
  bool get _hasNumber =>
      Get.find<AuthController>().newPasswordController.text.contains(RegExp(r'\d'));
  bool get _hasSymbol => Get.find<AuthController>()
      .newPasswordController
      .text
      .contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  bool get _hasMixedCase {
    final pw = Get.find<AuthController>().newPasswordController.text;
    return pw.contains(RegExp(r'[a-z]')) && pw.contains(RegExp(r'[A-Z]'));
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'MIXÉRA',
                style: AppTextStyles.logo.copyWith(
                  color: AppColors.blushPink,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Reset Password',
                style: AppTextStyles.headline.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your new password must be different\nfrom previously used passwords.',
                textAlign: TextAlign.center,
                style: AppTextStyles.description.copyWith(height: 1.5),
              ),
              const SizedBox(height: 48),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 60),
                    padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushPink.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter OTP Code', style: AppTextStyles.description),
                        const SizedBox(height: 12),

                        OtpInputField(controllers: authC.resetOtpControllers),

                        const SizedBox(height: 24),

                        Text('New Password', style: AppTextStyles.description),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: authC.newPasswordController,
                            obscureText: authC.isResetPasswordHidden.value,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Enter New Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authC.isResetPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.secondaryText,
                                ),
                                onPressed: authC.toggleResetPasswordVisibility,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.4,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.blushPink,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        _PasswordRequirementRow(
                            label: 'Minimum 8 characters', met: _hasMinLength),
                        _PasswordRequirementRow(
                            label: 'Include a number', met: _hasNumber),
                        _PasswordRequirementRow(
                            label: 'Include a symbol (!@#\$)', met: _hasSymbol),
                        _PasswordRequirementRow(
                            label: 'Mix of upper & lowercase letters',
                            met: _hasMixedCase),

                        const SizedBox(height: 20),

                        Text('Confirm Password', style: AppTextStyles.description),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: authC.confirmPasswordController,
                            obscureText: authC.isResetConfirmPasswordHidden.value,
                            decoration: InputDecoration(
                              hintText: 'Confirm New Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authC.isResetConfirmPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.secondaryText,
                                ),
                                onPressed:
                                    authC.toggleResetConfirmPasswordVisibility,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.4,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.blushPink,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Obx(
                          () => ElevatedButton(
                            onPressed: authC.isLoading.value
                                ? null
                                : () => authC.resetPassword(context,
                                    email: widget.email),
                            child: authC.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Reset Password'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.warmCream,
                      border: Border.all(color: Colors.white, width: 6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushPink.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 50,
                        color: AppColors.blushPink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Back',
                  style: AppTextStyles.description.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirementRow extends StatelessWidget {
  final String label;
  final bool met;

  const _PasswordRequirementRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_rounded : Icons.circle_outlined,
            size: 16,
            color: met ? AppColors.blushPink : AppColors.secondaryText,
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }
}
