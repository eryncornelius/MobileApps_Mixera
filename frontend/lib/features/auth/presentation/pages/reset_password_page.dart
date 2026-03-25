import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
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
                'Enter the OTP code sent to your email\nand create a new password.',
                textAlign: TextAlign.center,
                style: AppTextStyles.description.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                textAlign: TextAlign.center,
                style: AppTextStyles.description.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
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
                        Text('OTP Code', style: AppTextStyles.description),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: authC.resetCodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Enter 4-digit OTP',
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text('New Password', style: AppTextStyles.description),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: authC.newPasswordController,
                            obscureText: authC.isResetPasswordHidden.value,
                            decoration: InputDecoration(
                              hintText: 'Enter New Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authC.isResetPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.primaryText,
                                ),
                                onPressed: authC.toggleResetPasswordVisibility,
                              ),
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Confirm Password',
                          style: AppTextStyles.description,
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: authC.confirmPasswordController,
                            obscureText:
                                authC.isResetConfirmPasswordHidden.value,
                            decoration: InputDecoration(
                              hintText: 'Confirm New Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authC.isResetConfirmPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.primaryText,
                                ),
                                onPressed:
                                    authC.toggleResetConfirmPasswordVisibility,
                              ),
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.4,
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
                                : () => authC.resetPassword(
                                    context,
                                    email: email,
                                  ),
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
                onTap: () {
                  Navigator.pop(context);
                },
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
