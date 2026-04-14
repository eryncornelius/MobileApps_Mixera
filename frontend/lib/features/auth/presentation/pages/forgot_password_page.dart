import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                'Forgot Password?',
                style: AppTextStyles.headline.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.description.copyWith(height: 1.6),
                  children: [
                    const TextSpan(text: 'Dont Worry, it happens!\nPlease enter your '),
                    TextSpan(
                      text: 'email address',
                      style: AppTextStyles.description.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const TextSpan(
                      text: ' and\nwe\'ll send you instructions to reset your password.',
                    ),
                  ],
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
                        Text(
                          'Enter Your Email',
                          style: AppTextStyles.description,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: authC.forgotEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Example@gmail.com',
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.blushPink,
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
                        const SizedBox(height: 24),
                        Obx(
                          () => ElevatedButton(
                            onPressed: authC.isLoading.value
                                ? null
                                : () => authC.sendForgotPasswordCode(context),
                            child: authC.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Send Reset Code'),
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
                  'Back to Log in',
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
