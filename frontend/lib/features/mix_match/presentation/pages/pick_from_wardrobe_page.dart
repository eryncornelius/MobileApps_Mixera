import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../controllers/mix_match_controller.dart';
import 'confirm_items_page.dart';

class PickFromWardrobePage extends StatefulWidget {
  const PickFromWardrobePage({super.key});

  @override
  State<PickFromWardrobePage> createState() => _PickFromWardrobePageState();
}

class _PickFromWardrobePageState extends State<PickFromWardrobePage> {
  int _tabIndex = 0;
  late final MixMatchController _mix;

  @override
  void initState() {
    super.initState();
    _mix = Get.find<MixMatchController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mix.startNewSession();
      if (mounted) {
        await _mix.loadPickerCategory(kWardrobePickerCategoryTabs[_tabIndex].$2);
      }
    });
  }

  Future<void> _onTab(int index) async {
    setState(() => _tabIndex = index);
    await _mix.loadPickerCategory(kWardrobePickerCategoryTabs[index].$2);
  }

  Future<void> _addToOutfit() async {
    final session = await _mix.submitSelection();
    if (!mounted || session == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmItemsPage(session: session)),
    );
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
          'Pick From Wardrobe',
          style: AppTextStyles.headline.copyWith(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 45,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.blushPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(22.5),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: kWardrobePickerCategoryTabs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, index) {
                    final isSelected = index == _tabIndex;
                    return GestureDetector(
                      onTap: () => _onTab(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.blushPink.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          kWardrobePickerCategoryTabs[index].$1,
                          style: AppTextStyles.productName.copyWith(
                            color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    final n = _mix.selectedItemIds.length;
                    return Text(
                      '$n / 5 selected',
                      style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  _mix.selectedItemIds.length;
                  if (_mix.isBusy.value && _mix.currentSession.value == null) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.blushPink));
                  }
                  if (_mix.isLoadingPicker.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.blushPink));
                  }
                  if (_mix.pickerItems.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Tidak ada item di kategori ini.',
                          style: AppTextStyles.description,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _mix.pickerItems.length,
                    itemBuilder: (context, index) {
                      final item = _mix.pickerItems[index];
                      final isSelected = _mix.isSelected(item.id);
                      return GestureDetector(
                        onTap: () => _mix.toggleItem(item),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.softWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.blushPink : AppColors.border,
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _itemThumb(item),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check : Icons.add,
                                    color: AppColors.blushPink,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      isSelected ? 'Added' : 'Add',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.productName.copyWith(
                                        color: AppColors.blushPink,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.roseMist.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.softWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.button.copyWith(color: AppColors.primaryText),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Obx(() {
                        final busy = _mix.isBusy.value;
                        return SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: busy ? null : _addToOutfit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blushPink,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    'Add to outfit',
                                    style: AppTextStyles.button,
                                  ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _itemThumb(WardrobeItemApiModel item) {
    final url = resolveMediaUrl(item.image);
    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        color: AppColors.warmCream,
        child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 30),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.warmCream,
        child: const Icon(Icons.checkroom, color: AppColors.roseMist, size: 30),
      ),
    );
  }
}
