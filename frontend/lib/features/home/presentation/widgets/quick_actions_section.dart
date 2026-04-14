import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/quick_action_model.dart';

class QuickActionsSection extends StatelessWidget {
  final List<QuickActionModel> actions;
  final void Function(QuickActionModel)? onActionTap;

  const QuickActionsSection({
    super.key,
    required this.actions,
    this.onActionTap,
  });

  IconData _iconForName(String name) {
    switch (name) {
      case 'shirt':
        return Icons.checkroom_outlined;
      case 'sparkles':
        return Icons.auto_awesome_outlined;
      case 'heart':
        return Icons.favorite_border_rounded;
      case 'bag':
        return Icons.shopping_bag_outlined;
      case 'bookmark':
        return Icons.bookmark_outline_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.section),
        const SizedBox(height: 14),
        // Action grid — lebar merata agar label panjang tidak mudah patah 2 baris
        Row(
          children: actions.map((action) {
            return Expanded(
              child: _ActionItem(
                label: action.label,
                icon: _iconForName(action.iconName),
                onTap: () => onActionTap?.call(action),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionItem({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.blushPink, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
                fontSize: 10.5,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
