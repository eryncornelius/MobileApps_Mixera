import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';
import '../widgets/social_login_buttons.dart';
import '../../../../app/routes/route_names.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool get _hasMinLength =>
      Get.find<AuthController>().passwordController.text.length >= 8;
  bool get _hasNumber =>
      Get.find<AuthController>().passwordController.text.contains(RegExp(r'\d'));
  bool get _hasSymbol => Get.find<AuthController>()
      .passwordController
      .text
      .contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  bool get _hasMixedCase {
    final pw = Get.find<AuthController>().passwordController.text;
    return pw.contains(RegExp(r'[a-z]')) && pw.contains(RegExp(r'[A-Z]'));
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'Create an account',
                style: AppTextStyles.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect with your friends today!',
                style: AppTextStyles.description,
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: authC.usernameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Your Username',
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: authC.emailController,
                decoration: const InputDecoration(hintText: 'Enter Your Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: authC.phoneController,
                decoration: const InputDecoration(
                  hintText: 'Enter Your Phone Number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              Obx(
                () => TextFormField(
                  controller: authC.passwordController,
                  obscureText: authC.isPasswordHidden.value,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Enter Your Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        authC.isPasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.primaryText,
                      ),
                      onPressed: authC.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _PasswordRequirementRow(label: 'Minimum 8 characters', met: _hasMinLength),
              _PasswordRequirementRow(label: 'Include a number', met: _hasNumber),
              _PasswordRequirementRow(label: 'Include a symbol (!@#\$)', met: _hasSymbol),
              _PasswordRequirementRow(
                  label: 'Mix of upper & lowercase letters', met: _hasMixedCase),

              const SizedBox(height: 20),

              Obx(
                () => ElevatedButton(
                  onPressed: authC.isLoading.value
                      ? null
                      : () => authC.register(context),
                  child: authC.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 48),

              Obx(
                () => SocialLoginButtons(
                  onGoogleTap: authC.isLoading.value
                      ? null
                      : () => authC.continueWithGoogle(context),
                  onFacebookTap: authC.isLoading.value
                      ? null
                      : () => authC.continueWithFacebook(context),
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.description.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteNames.login,
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Login',
                      style: AppTextStyles.description.copyWith(
                        color: const Color(0xFF1877F2),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
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
