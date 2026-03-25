import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';
import '../widgets/social_login_buttons.dart';
import '../../../../app/routes/route_names.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
              const SizedBox(height: 32),

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
