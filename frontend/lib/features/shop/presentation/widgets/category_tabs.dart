import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../controllers/shop_controller.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final shopC = Get.find<ShopController>();

    return Obx(() {
      final cats = shopC.categories;
      final selected = shopC.selectedCategorySlug.value;

      final tabs = <_Tab>[
        const _Tab(slug: '', label: 'All'),
        ...cats.map((c) => _Tab(slug: c.slug, label: c.name)),
      ];

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: tabs.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final tab = tabs[i];
            final isSelected = tab.slug == selected;
            return GestureDetector(
              onTap: () => shopC.selectCategory(tab.slug),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blushPink : AppColors.softWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.blushPink : AppColors.border,
                  ),
                ),
                child: Text(
                  tab.label,
                  style: AppTextStyles.type.copyWith(
                    color: isSelected ? Colors.white : AppColors.primaryText,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _Tab {
  final String slug;
  final String label;
  const _Tab({required this.slug, required this.label});
}
