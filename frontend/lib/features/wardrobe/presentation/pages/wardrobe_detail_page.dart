import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/wardrobe_api_models.dart';
import '../controllers/wardrobe_controller.dart';
import 'wardrobe_batch_review_page.dart';

class WardrobeDetailPage extends StatefulWidget {
  final String categorySlug;
  final String displayTitle;
  final int itemCountHint;

  const WardrobeDetailPage({
    super.key,
    required this.categorySlug,
    required this.displayTitle,
    required this.itemCountHint,
  });

  @override
  State<WardrobeDetailPage> createState() => _WardrobeDetailPageState();
}

class _WardrobeDetailPageState extends State<WardrobeDetailPage> {
  final WardrobeController _c = Get.find<WardrobeController>();

  @override
  void initState() {
    super.initState();
    _c.loadItemsForCategory(widget.categorySlug);
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
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final n = _c.categoryItems.length;
                  final count = _c.isLoadingItems.value && n == 0 ? widget.itemCountHint : n;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            text: 'You own ',
                            style: AppTextStyles.headline.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: '$count ',
                                style: const TextStyle(color: AppColors.secondaryText),
                              ),
                              TextSpan(text: widget.displayTitle.toLowerCase()),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showFilterSheet(context),
                        child: Obx(() {
                          final favActive = _c.isFavouritesFilter.value;
                          final styleActive = _c.selectedStyleTag.value.isNotEmpty;
                          final active = favActive || styleActive;
                          final filterLabel = favActive
                              ? 'Favourites'
                              : styleActive
                                  ? _c.selectedStyleTag.value
                                  : 'Filter';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? AppColors.blushPink : AppColors.softWhite,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                              border: Border.all(
                                color: active ? AppColors.blushPink : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_alt_outlined,
                                  color: active ? Colors.white : AppColors.secondaryText,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  active ? filterLabel : 'Filter',
                                  style: AppTextStyles.productName.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: active ? Colors.white : AppColors.primaryText,
                                  ),
                                ),
                                if (active) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      _c.clearStyleTagFilter();
                                    },
                                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      )
                    ],
                  );
                }),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (_c.isLoadingItems.value && _c.categoryItems.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.blushPink),
                      );
                    }
                    if (_c.categoryItems.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Belum ada item di kategori ini.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.description,
                          ),
                        ),
                      );
                    }
                    final items = _c.filteredCategoryItems;
                    if (items.isEmpty) {
                      final emptyMsg = _c.isFavouritesFilter.value
                          ? 'Belum ada item favourite di kategori ini.'
                          : _c.selectedStyleTag.value.isNotEmpty
                              ? 'Tidak ada item dengan tag "${_c.selectedStyleTag.value}".'
                              : 'Tidak ada item yang cocok dengan filter.';
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            emptyMsg,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.description,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(context, items[index]);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.warmCream.withValues(alpha: 0.0),
                    AppColors.warmCream.withValues(alpha: 0.9),
                    AppColors.warmCream,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Something isn\'t here?',
                    style: AppTextStyles.description.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final busy = _c.isUploading.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: busy
                            ? null
                            : () async {
                                final paths = await _pickImagePaths(context);
                                if (paths == null || paths.isEmpty) return;
                                final batch = await _c.uploadPhotos(paths);
                                if (!context.mounted || batch == null) return;
                                final done = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => WardrobeBatchReviewPage(
                                      batch: batch,
                                      presetCategorySlug: widget.categorySlug,
                                    ),
                                  ),
                                );
                                if (done == true && context.mounted) {
                                  await _c.loadItemsForCategory(widget.categorySlug);
                                  await _c.loadCategorySummary();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blushPink,
                          disabledBackgroundColor: AppColors.blushPink.withValues(alpha: 0.55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.blushPink.withValues(alpha: 0.4),
                        ),
                        child: busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                '+ Add Clothes',
                                style: AppTextStyles.button,
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final tags = _c.availableStyleTags;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.warmCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Obx(() {
        final selected = _c.selectedStyleTag.value;
        final favOnly = _c.isFavouritesFilter.value;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter',
                style: AppTextStyles.headline.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _filterChip(
                    label: 'All',
                    selected: !favOnly && selected.isEmpty,
                    onTap: () {
                      _c.clearStyleTagFilter();
                      Navigator.pop(context);
                    },
                  ),
                  _filterChip(
                    label: 'Favourites',
                    selected: favOnly,
                    onTap: () {
                      _c.setFavouritesFilter();
                      Navigator.pop(context);
                    },
                  ),
                  ...tags.map((tag) => _filterChip(
                        label: tag,
                        selected: !favOnly && selected == tag,
                        onTap: () {
                          _c.clearStyleTagFilter();
                          _c.selectedStyleTag.value = tag;
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.blushPink : AppColors.softWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.blushPink : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.productName.copyWith(
            color: selected ? Colors.white : AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WardrobeItemApiModel item) async {
    final initial = item.name.trim().isNotEmpty
        ? item.name
        : (item.subcategory.trim().isNotEmpty ? item.subcategory : item.category);
    final ctrl = TextEditingController(text: initial);
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.softWhite,
          title: Text('Nama item', style: AppTextStyles.section),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 120,
            decoration: InputDecoration(
              hintText: 'Nama panggilan di wardrobe',
              hintStyle: AppTextStyles.small,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            style: AppTextStyles.description,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: AppTextStyles.small.copyWith(color: AppColors.secondaryText)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Simpan', style: AppTextStyles.small.copyWith(color: AppColors.blushPink, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      final name = ctrl.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong.')),
        );
        return;
      }
      await _c.renameItem(item, name);
    } finally {
      // Dispose after the dialog route has unmounted the TextField; otherwise
      // Framework hits '_dependents.isEmpty' when cancelling (controller vs. listeners).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.dispose();
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context, WardrobeItemApiModel item) async {
    final title = item.name.trim().isNotEmpty
        ? item.name
        : (item.subcategory.trim().isNotEmpty ? item.subcategory : item.category);
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.softWhite,
        title: Text('Hapus item?', style: AppTextStyles.section),
        content: Text(
          'Yakin hapus “$title” dari wardrobe? Tindakan ini tidak bisa dibatalkan.',
          style: AppTextStyles.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppTextStyles.small.copyWith(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: AppTextStyles.small.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    await _c.deleteItem(item.id);
  }

  Widget _buildItemCard(BuildContext context, WardrobeItemApiModel item) {
    final url = resolveMediaUrl(item.image);
    final title = item.name.trim().isNotEmpty
        ? item.name
        : (item.subcategory.trim().isNotEmpty ? item.subcategory : item.category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.productName.copyWith(
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 2,
                      color: AppColors.blushPink,
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _c.toggleFavourite(item),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Obx(() {
                      final cur = _c.categoryItems.firstWhereOrNull((i) => i.id == item.id) ?? item;
                      return Icon(
                        cur.isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: cur.isFavourite ? AppColors.blushPink : Colors.grey.shade400,
                        size: 22,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url.isNotEmpty
                  ? Image.network(
                      url,
                      height: 96,
                      width: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showRenameDialog(context, item),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: AppColors.blushPink),
                        const SizedBox(width: 4),
                        Text('Edit nama', style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmDelete(context, item),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 20, color: AppColors.blushPink),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 96,
      width: 96,
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 40),
    );
  }
}
