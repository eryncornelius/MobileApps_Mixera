import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SecurityOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;
  final List<Widget>? children;

  const SecurityOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.roseMist,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.blushPink, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.productName),
                    const SizedBox(height: 2),
                    Text(description, style: AppTextStyles.small),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (children case final kids?) ...[
            const SizedBox(height: 14),
            ...kids,
          ],
        ],
      ),
    );
  }
}
