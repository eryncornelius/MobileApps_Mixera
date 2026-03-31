import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class SearchHistorySection extends StatelessWidget {
  final String title;
  final List<String> items;
  final VoidCallback? onClearAll;
  final void Function(String) onTap;

  const SearchHistorySection({
    super.key,
    required this.title,
    required this.items,
    required this.onTap,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.section.copyWith(fontSize: 15)),
              if (onClearAll != null)
                GestureDetector(
                  onTap: onClearAll,
                  child: Text('Clear all',
                      style: AppTextStyles.small.copyWith(color: AppColors.blushPink)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((q) {
              return GestureDetector(
                onTap: () => onTap(q),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.roseMist,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(q,
                      style: AppTextStyles.small.copyWith(color: AppColors.primaryText)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
