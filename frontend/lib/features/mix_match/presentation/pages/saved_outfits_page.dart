import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/mix_match_api_models.dart';
import '../controllers/mix_match_controller.dart';
import 'outfit_result_page.dart';

class SavedOutfitsPage extends StatefulWidget {
  const SavedOutfitsPage({super.key});

  @override
  State<SavedOutfitsPage> createState() => _SavedOutfitsPageState();
}

class _SavedOutfitsPageState extends State<SavedOutfitsPage> {
  final _mix = Get.find<MixMatchController>();

  @override
  void initState() {
    super.initState();
    _mix.refreshSavedMixOutfits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Outfits',
          style: AppTextStyles.headline.copyWith(fontSize: 22),
        ),
      ),
      body: Obx(() {
        if (_mix.savedMixOutfits.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.checkroom_outlined,
                  size: 64,
                  color: AppColors.secondaryText.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text('Belum ada outfit tersimpan', style: AppTextStyles.description),
                const SizedBox(height: 8),
                Text(
                  'Generate mix & match lalu tap simpan',
                  style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.blushPink,
          onRefresh: _mix.refreshSavedMixOutfits,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: _mix.savedMixOutfits.length,
            itemBuilder: (context, index) {
              return _OutfitCard(
                outfit: _mix.savedMixOutfits[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OutfitResultPage(
                      preloadedResult: _mix.savedMixOutfits[index],
                    ),
                  ),
                ).then((_) => _mix.refreshSavedMixOutfits()),
                onUnsave: () => _mix.toggleSave(_mix.savedMixOutfits[index].id),
              );
            },
          ),
        );
      }),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final MixResultDetailModel outfit;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  const _OutfitCard({
    required this.outfit,
    required this.onTap,
    required this.onUnsave,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _itemsLabel() {
    final cats = outfit.selectedItems.map((i) => i.category).toSet().toList();
    final display = cats.take(3).join(', ');
    return cats.length > 3 ? '$display +${cats.length - 3}' : display;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    outfit.styleLabel,
                    style: AppTextStyles.productName.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onUnsave,
                  child: const Icon(Icons.favorite, color: AppColors.blushPink, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Date & categories
            Row(
              children: [
                Text(
                  _formatDate(outfit.createdAt),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _itemsLabel(),
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Preview image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: outfit.previewImage != null
                    ? Image.network(
                        outfit.previewImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 10),

            // Score badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.warmCream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Preview',
                    style: AppTextStyles.type.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      fontSize: 11,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blushPink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${outfit.score}%',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.blushPink,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      color: AppColors.roseMist.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 40),
      ),
    );
  }
}
