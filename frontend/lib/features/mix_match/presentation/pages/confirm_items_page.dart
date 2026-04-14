import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../../data/models/mix_match_api_models.dart';
import '../controllers/mix_match_controller.dart';
import 'outfit_result_page.dart';

class ConfirmItemsPage extends StatefulWidget {
  final MixSessionModel session;

  const ConfirmItemsPage({super.key, required this.session});

  @override
  State<ConfirmItemsPage> createState() => _ConfirmItemsPageState();
}

class _ConfirmItemsPageState extends State<ConfirmItemsPage> {
  late final MixMatchController _mix;

  @override
  void initState() {
    super.initState();
    _mix = Get.find<MixMatchController>();
    _mix.currentSession.value = widget.session;
  }

  Future<void> _mixOutfit() async {
    // Navigate immediately — OutfitResultPage calls generateMix() internally
    // and shows a proper generating state while the backend processes.
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OutfitResultPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.session.selectedItems;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications_none, color: AppColors.blushPink, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'MIXÉRA',
              style: AppTextStyles.logo.copyWith(
                color: AppColors.blushPink,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirm Your Items',
              style: AppTextStyles.headline.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Let AI mix your clothes into a stylish outfit',
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Tidak ada item terpilih.', style: AppTextStyles.description),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 96,
                              child: _ConfirmTile(item: item),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Looks great! Ready to mix them all into a stylish outfit?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.description.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    final busy = _mix.isBusy.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: items.isEmpty || busy ? null : _mixOutfit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blushPink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Mix Outfit', style: AppTextStyles.button),
                                  const SizedBox(width: 4),
                                  const Text('✨', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.softWhite,
                        side: BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmTile extends StatelessWidget {
  final WardrobeItemApiModel item;

  const _ConfirmTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(item.image);
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  item.name.isNotEmpty ? item.name : item.category,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productName.copyWith(fontSize: 11),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, _, _) => _ph(),
                          )
                        : _ph(),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.edit, size: 10, color: AppColors.secondaryText),
            ),
          )
        ],
      ),
    );
  }

  Widget _ph() {
    return Container(
      color: AppColors.warmCream,
      child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 28),
    );
  }
}
