import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/remember_me_row.dart';
import '../widgets/social_login_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(),

              Text('Email', style: AppTextStyles.description),
              const SizedBox(height: 8),
              TextFormField(
                controller: authC.emailController,
                decoration: const InputDecoration(
                  hintText: 'example@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              Text('Password', style: AppTextStyles.description),
              const SizedBox(height: 8),

              Obx(
                () => TextFormField(
                  controller: authC.passwordController,
                  obscureText: authC.isPasswordHidden.value,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        authC.isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primaryText,
                      ),
                      onPressed: authC.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(child: RememberMeRow()),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.blushPink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Obx(
                () => ElevatedButton(
                  onPressed: authC.isLoading.value
                      ? null
                      : () => authC.login(context),
                  child: authC.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Login'),
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
                    'Don\'t have an account ? ',
                    style: AppTextStyles.description.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.register);
                    },
                    child: Text(
                      'Sign Up',
                      style: AppTextStyles.description.copyWith(
                        color: const Color(0xFF000080),
                        fontWeight: FontWeight.bold,
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
