import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SocialLoginButtons extends StatelessWidget {
  // Tambahkan variabel ini agar teks bisa berubah (Login / Register)
  final String actionText;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  const SocialLoginButtons({
    super.key,
    this.actionText = 'Login',
    this.onGoogleTap,
    this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or With',
                style: AppTextStyles.description.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 32),

        // Facebook Button
        ElevatedButton(
          onPressed: onFacebookTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2), // Facebook Blue
            foregroundColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.facebook, size: 24),
              const SizedBox(width: 12),
              Text('$actionText with Facebook', style: AppTextStyles.button),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Google Button
        OutlinedButton(
          onPressed: onGoogleTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryText,
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                '$actionText with Google',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
