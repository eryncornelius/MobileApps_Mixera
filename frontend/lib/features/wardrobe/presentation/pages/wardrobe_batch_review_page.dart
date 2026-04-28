import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/wardrobe_api_models.dart';
import '../controllers/wardrobe_controller.dart';

/// Review detected candidates before confirming into the wardrobe (PATCH + POST confirm).
class WardrobeBatchReviewPage extends StatefulWidget {
  final UploadBatchDetailModel batch;

  /// When set (e.g. opened from a category detail screen), all candidates use this slug before confirm.
  final String? presetCategorySlug;

  const WardrobeBatchReviewPage({
    super.key,
    required this.batch,
    this.presetCategorySlug,
  });

  @override
  State<WardrobeBatchReviewPage> createState() => _WardrobeBatchReviewPageState();
}

class _WardrobeBatchReviewPageState extends State<WardrobeBatchReviewPage> {
  late List<DetectedItemCandidateModel> _candidates;
  late final Map<int, String> _photoImageById;
  final WardrobeController _c = Get.find<WardrobeController>();

  @override
  void initState() {
    super.initState();
    var list = widget.batch.allCandidates.toList();
    final preset = widget.presetCategorySlug;
    if (preset != null && preset.isNotEmpty) {
      list = list.map((c) => c.copyWith(category: preset)).toList();
    }
    _candidates = list;
    _photoImageById = {for (final p in widget.batch.photos) p.id: p.image};
  }

  String _thumbPathFor(DetectedItemCandidateModel item) {
    final crop = item.croppedImage;
    if (crop != null && crop.isNotEmpty) return crop;
    final src = _photoImageById[item.photoId];
    return src ?? '';
  }

  void _toggle(int index) {
    setState(() {
      final c = _candidates[index];
      _candidates[index] = c.copyWith(isSelected: !c.isSelected);
    });
  }

  Future<void> _confirm() async {
    if (!_candidates.any((e) => e.isSelected)) {
      Get.snackbar('Wardrobe', 'Pilih minimal satu item.');
      return;
    }
    final patched = await _c.patchCandidates(widget.batch.id, _candidates);
    if (!patched || !mounted) return;
    final items = await _c.confirmReviewBatch(widget.batch.id);
    if (!mounted) return;
    if (items != null) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Review items', style: AppTextStyles.section),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Pilih item yang ingin ditambahkan ke wardrobe Anda.',
              style: AppTextStyles.description,
            ),
          ),
          Expanded(
            child: _candidates.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada item terdeteksi pada foto ini.',
                      style: AppTextStyles.description,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _candidates.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _candidates[index];
                      final thumb = resolveMediaUrl(_thumbPathFor(item));
                      return Material(
                        color: AppColors.softWhite,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _toggle(index),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: thumb.isNotEmpty
                                      ? Image.network(
                                          thumb,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) => _placeholderThumb(),
                                        )
                                      : _placeholderThumb(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.category.toUpperCase(),
                                        style: AppTextStyles.small.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.blushPink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.subcategory.isNotEmpty
                                            ? item.subcategory
                                            : item.color.isNotEmpty
                                                ? item.color
                                                : 'Detected item',
                                        style: AppTextStyles.productName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: item.isSelected,
                                  activeColor: AppColors.blushPink,
                                  onChanged: (_) => _toggle(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Obx(() {
              final loading = _c.isConfirming.value;
              return SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blushPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Add to Wardrobe', style: AppTextStyles.button),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.warmCream,
      child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 32),
    );
  }
}
