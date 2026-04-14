import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/dashboard_model.dart';

class WardrobePreviewSection extends StatelessWidget {
  final List<WardrobeItemModel> items;
  final VoidCallback? onViewAll;

  const WardrobePreviewSection({
    super.key,
    required this.items,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Wardrobe', style: AppTextStyles.section),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Inner header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wardrobe',
                    style: AppTextStyles.type.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'View all →',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.blushPink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No items yet — add clothes from Wardrobe.',
                          style: AppTextStyles.description,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.roseMist,
                                child: const Icon(
                                  Icons.checkroom_outlined,
                                  color: AppColors.blushPink,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
