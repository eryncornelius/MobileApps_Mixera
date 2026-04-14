import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../tryon/data/models/tryon_api_models.dart';
import '../../../tryon/presentation/controllers/tryon_controller.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import 'saved_try_on_detail_page.dart';

class SavedTryOnPhotosPage extends StatefulWidget {
  const SavedTryOnPhotosPage({super.key});

  @override
  State<SavedTryOnPhotosPage> createState() => _SavedTryOnPhotosPageState();
}

class _SavedTryOnPhotosPageState extends State<SavedTryOnPhotosPage> {
  late final TryOnController _tryOn;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tryOn = Get.find<TryOnController>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _tryOn.refreshSavedTryOnResults();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText, size: 20),
        ),
        title: Text(
          'My Try-On Photos',
          style: AppTextStyles.headline.copyWith(fontSize: 22),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blushPink))
          : Obx(() {
              final items = _tryOn.savedTryOnEntries;
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.blushPink),
                        const SizedBox(height: 12),
                        Text('Belum ada foto try-on tersimpan', style: AppTextStyles.section),
                        const SizedBox(height: 6),
                        Text(
                          'Tap ikon hati di hasil try-on untuk menyimpan ke sini.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.description,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.blushPink,
                onRefresh: _load,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, i) => _SavedCard(
                    item: items[i],
                    onOpenDetail: () async {
                      final removed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SavedTryOnDetailPage(entry: items[i]),
                        ),
                      );
                      if (removed == true && context.mounted) await _load();
                    },
                  ),
                ),
              );
            }),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final TryOnSavedEntryModel item;
  final VoidCallback onOpenDetail;

  const _SavedCard({required this.item, required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    final img = resolveMediaUrl(item.resultImage);
    return Material(
      color: AppColors.softWhite,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: img.isEmpty
                      ? Container(
                          color: AppColors.roseMist,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.secondaryText),
                        )
                      : Image.network(
                          img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.roseMist,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined, color: AppColors.secondaryText),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Text(
                  item.sourceType == 'shop_product' ? 'From Shop Product' : 'From Mix Outfit',
                  style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
