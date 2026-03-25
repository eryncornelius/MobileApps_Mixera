import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final VoidCallback? onNotificationTap;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTextStyles.headline),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.description),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primaryText,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
