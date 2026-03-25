import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Text(
            'Hi, Welcome Back! 👋',
            style: AppTextStyles.headline.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
