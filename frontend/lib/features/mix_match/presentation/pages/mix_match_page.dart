import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../../data/models/mix_match_api_models.dart';
import '../controllers/mix_match_controller.dart';
import 'pick_from_wardrobe_page.dart';

class MixMatchPage extends StatefulWidget {
  const MixMatchPage({super.key});

  @override
  State<MixMatchPage> createState() => _MixMatchPageState();
}

class _MixMatchPageState extends State<MixMatchPage> {
  late final MixMatchController _mix;

  @override
  void initState() {
    super.initState();
    _mix = Get.find<MixMatchController>();
    _mix.loadSpotlightItems();
  }

  void _openPick() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PickFromWardrobePage()),
    ).then((_) {
      _mix.loadSpotlightItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20, top: 10),
            child: Icon(Icons.notifications_none, color: AppColors.blushPink, size: 28),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.blushPink,
        onRefresh: () => _mix.loadSpotlightItems(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  'Mix & Match',
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Let AI mix your clothes into a stylish outfit',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.description,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Clothing Recommendations',
                style: AppTextStyles.section,
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_mix.isLoadingSpotlight.value && _mix.spotlightItems.isEmpty) {
                  return const SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blushPink),
                    ),
                  );
                }
                if (_mix.spotlightItems.isEmpty) {
                  return Container(
                    height: 120,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Belum ada item wardrobe. Tambahkan di tab Wardrobe dulu.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.description,
                    ),
                  );
                }
                return SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mix.spotlightItems.length,
                    itemBuilder: (context, index) {
                      final item = _mix.spotlightItems[index];
                      return _SpotlightCard(
                        item: item,
                        onTap: _openPick,
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _openPick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blushPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pick From Wardrobe',
                    style: TextStyle(
                      color: AppColors.softWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Your Outfit Recommendation',
                style: AppTextStyles.section,
              ),
              const SizedBox(height: 16),
              Obx(() {
                final r = _mix.currentResult.value;
                if (r != null) {
                  return _LatestMixCard(
                    result: r,
                    mix: _mix,
                    onOpenPick: _openPick,
                  );
                }
                return _PlaceholderMixCard(onPick: _openPick);
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final WardrobeItemApiModel item;
  final VoidCallback onTap;

  const _SpotlightCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(item.image);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: url.isNotEmpty
                    ? Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ph(),
                      )
                    : _ph(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name.isNotEmpty ? item.name : item.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.productName.copyWith(fontSize: 12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.blushPink, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Mix',
                  style: AppTextStyles.productName.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 14,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _ph() {
    return Container(
      width: double.infinity,
      color: AppColors.warmCream,
      child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 40),
    );
  }
}

class _LatestMixCard extends StatelessWidget {
  final MixResultDetailModel result;
  final MixMatchController mix;
  final VoidCallback onOpenPick;

  const _LatestMixCard({
    required this.result,
    required this.mix,
    required this.onOpenPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.styleLabel,
                      style: AppTextStyles.headline.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Score ${result.score}/100',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.blushPink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.explanation.isNotEmpty
                          ? result.explanation
                          : 'Hasil mix terbaru Anda.',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.productName.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.35,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 140,
                    child: ColoredBox(
                      color: AppColors.roseMist.withValues(alpha: 0.15),
                      child: Center(child: _miniVisual(result)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final saved = mix.currentResult.value?.isSaved ?? false;
            final busy = mix.isSavingResult.value;
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: busy
                        ? null
                        : () async {
                            await mix.toggleSave(result.id);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blushPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            saved ? 'Saved ✓' : 'Save Outfit',
                            style: const TextStyle(
                              color: AppColors.softWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onOpenPick,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      'Try Another',
                      style: TextStyle(color: AppColors.blushPink, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _miniVisual(MixResultDetailModel result) {
    final preview = result.previewImage;
    if (preview != null && preview.isNotEmpty) {
      final u = resolveMediaUrl(preview);
      if (u.isNotEmpty) {
        return Image.network(
          u,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _miniVisualFromItems(result.selectedItems),
        );
      }
    }
    return _miniVisualFromItems(result.selectedItems);
  }

  Widget _miniVisualFromItems(List<WardrobeItemApiModel> items) {
    if (items.isEmpty) {
      return Container(
        color: AppColors.warmCream,
        child: const Center(
          child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 48),
        ),
      );
    }
    final u = resolveMediaUrl(items.first.image);
    if (u.isEmpty) {
      return Container(
        color: AppColors.warmCream,
        child: const Center(
          child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 48),
        ),
      );
    }
    return Image.network(
      u,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.warmCream,
        child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 48),
      ),
    );
  }
}

class _PlaceholderMixCard extends StatelessWidget {
  final VoidCallback onPick;

  const _PlaceholderMixCard({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada hasil mix',
                  style: AppTextStyles.productName.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih item dari wardrobe lalu generate outfit dengan AI.',
                  style: AppTextStyles.description,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onPick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blushPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start mixing',
                      style: TextStyle(color: AppColors.softWhite, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.checkroom, color: AppColors.roseMist, size: 80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
