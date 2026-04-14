import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../mix_match/presentation/controllers/mix_match_controller.dart';
import '../controllers/wardrobe_controller.dart';
import 'wardrobe_batch_review_page.dart';
import 'wardrobe_detail_page.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  static IconData _iconForCategory(String slug) {
    switch (slug) {
      case 'outer':
        return Icons.layers;
      case 'top':
        return Icons.dry_cleaning;
      case 'bag':
        return Icons.shopping_bag_outlined;
      case 'bottom':
        return Icons.airline_seat_legroom_extra;
      case 'accessories':
        return Icons.watch_outlined;
      case 'shoes':
        return Icons.snowshoeing;
      case 'dress':
        return Icons.accessibility_new_outlined;
      case 'other':
      default:
        return Icons.checkroom;
    }
  }

  static String _labelForCategory(String slug) {
    switch (slug) {
      case 'top':
        return 'Top';
      case 'bottom':
        return 'Bottom';
      case 'outer':
        return 'Outer';
      case 'dress':
        return 'Dresses';
      case 'shoes':
        return 'Shoes';
      case 'bag':
        return 'Bags';
      case 'accessories':
        return 'Accessories';
      case 'other':
        return 'Other';
      default:
        return slug.isEmpty ? '' : slug[0].toUpperCase() + slug.substring(1);
    }
  }

  Future<List<String>?> _pickImagePaths(BuildContext context) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return null;
    if (files.length > 3) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maksimal 3 foto per unggahan.')),
        );
      }
      return files.take(3).map((f) => f.path).toList();
    }
    return files.map((f) => f.path).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WardrobeController>();
    final mix = Get.find<MixMatchController>()..refreshSavedMixOutfits();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              if (c.isLoadingSummary.value && c.categorySummary.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.blushPink),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'MIXÉRA',
                        style: AppTextStyles.logo.copyWith(
                          color: AppColors.blushPink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Wardrobe',
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Keep track of what you own',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.description.copyWith(height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Obx(() {
                      final busy = c.isUploading.value;
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.blushPink,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blushPink.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: busy
                                ? null
                                : () async {
                                    final paths = await _pickImagePaths(context);
                                    if (paths == null || paths.isEmpty) return;
                                    final batch = await c.uploadPhotos(paths);
                                    if (!context.mounted || batch == null) return;
                                    final done = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => WardrobeBatchReviewPage(batch: batch),
                                      ),
                                    );
                                    if (done == true && context.mounted) {
                                      await c.loadCategorySummary();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Upload Photos', style: AppTextStyles.button),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    // ── Saved Outfits Card ──────────────────────────────────
                    Obx(() {
                      final count = mix.savedMixOutfits.length;
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/saved-outfits'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.softWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.blushPink.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.blushPink,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saved Outfits',
                                      style: AppTextStyles.productName.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'You have $count Outfit${count == 1 ? '' : 's'}',
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.secondaryText,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Obx(() {
                      final list = c.categorySummary;
                      if (list.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Belum ada data kategori. Tarik untuk refresh setelah menambah item.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.description,
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: list.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final entry = list[index];
                          final title = _labelForCategory(entry.category);
                          return _buildCategoryCard(
                            context,
                            c,
                            title,
                            entry.category,
                            entry.count,
                            _iconForCategory(entry.category),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 120),
                  ],
                ),
              );
            }),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Obx(() {
                final pending = c.pendingReviewBatch.value;
                final canResume = pending != null && pending.status == 'review_ready';
                if (!canResume) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.warmCream.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: AppColors.softWhite,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: () => c.clearPendingReview(),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: AppColors.blushPink,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final b = c.pendingReviewBatch.value;
                              if (b == null || !context.mounted) return;
                              final fresh = await c.refreshBatch(b.id) ?? b;
                              if (!context.mounted) return;
                              final done = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => WardrobeBatchReviewPage(batch: fresh),
                                ),
                              );
                              if (done == true && context.mounted) {
                                await c.loadCategorySummary();
                              }
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(
                              'Add to Wardrobe',
                              style: AppTextStyles.button,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WardrobeController c,
    String title,
    String categorySlug,
    int count,
    IconData fallbackIcon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WardrobeDetailPage(
              categorySlug: categorySlug,
              displayTitle: title,
              itemCountHint: count,
            ),
          ),
        ).then((_) => c.loadCategorySummary());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.section.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$count',
                  style: AppTextStyles.description.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: 24,
              height: 2,
              color: AppColors.blushPink,
            ),
            const Spacer(),
            Center(
              child: Icon(
                fallbackIcon,
                size: 60,
                color: AppColors.warmCream.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
