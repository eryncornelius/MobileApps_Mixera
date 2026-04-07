import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../profile/data/models/address_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/checkout_controller.dart';

class AddressSelector extends StatelessWidget {
  const AddressSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutC = Get.find<CheckoutController>();
    final profileC = Get.find<ProfileController>();

    return Obx(() {
      final addresses = profileC.addresses;
      final selectedId = checkoutC.selectedAddressId.value;

      if (addresses.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text('No saved addresses. Add one in Profile.', style: AppTextStyles.description),
        );
      }

      // Auto-select primary (or first) address if nothing is selected yet
      if (selectedId == null) {
        final toSelect = addresses.firstWhereOrNull((a) => a.isPrimary) ?? addresses.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          checkoutC.selectedAddressId.value = toSelect.id;
        });
      }

      final selected = addresses.firstWhereOrNull((a) => a.id == selectedId) ?? addresses.first;
      return _AddressCard(
        address: selected,
        onTap: addresses.length > 1
            ? () => _showPicker(context, addresses, checkoutC)
            : null,
      );
    });
  }

  void _showPicker(
    BuildContext context,
    List<AddressModel> addresses,
    CheckoutController checkoutC,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Address', style: AppTextStyles.section),
            const SizedBox(height: 16),
            ...addresses.map((a) {
              final isSelected = a.id == checkoutC.selectedAddressId.value;
              return GestureDetector(
                onTap: () {
                  checkoutC.selectedAddressId.value = a.id;
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.roseMist : AppColors.softWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.blushPink : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _AddressText(address: a)),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.blushPink, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onTap;

  const _AddressCard({required this.address, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.roseMist,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_outlined, color: AppColors.blushPink, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: _AddressText(address: address)),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.blushPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}

class _AddressText extends StatelessWidget {
  final AddressModel address;
  const _AddressText({required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${address.label[0].toUpperCase()}${address.label.substring(1)} address',
          style: AppTextStyles.type,
        ),
        const SizedBox(height: 2),
        Text(address.recipientName, style: AppTextStyles.description),
        Text(
          '${address.streetAddress}, ${address.city}',
          style: AppTextStyles.small,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
