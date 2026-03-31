import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetPrimary;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final isHome = address.label == 'home';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.roseMist,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isHome ? Icons.home_rounded : Icons.work_rounded,
                    color: AppColors.blushPink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${address.label[0].toUpperCase()}${address.label.substring(1)} address',
                    style: AppTextStyles.productName,
                  ),
                ),
                if (address.isPrimary)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.roseMist,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.blushPink,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(address.recipientName, style: AppTextStyles.description.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(
              '${address.streetAddress} ${address.city}, ${address.state} ${address.postalCode}',
              style: AppTextStyles.description,
            ),
            const SizedBox(height: 2),
            Text(
              address.isPrimary ? 'Primary Address  ${address.phoneNumber}' : address.phoneNumber,
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (address.isPrimary) ...[
                  _PinkButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 10),
                  _OutlineButton(label: 'Delete', icon: Icons.delete_outline, onTap: onDelete),
                ] else ...[
                  _OutlineButton(
                    label: 'Set As Primary',
                    icon: Icons.check_box_outline_blank_rounded,
                    onTap: onSetPrimary ?? () {},
                  ),
                  const SizedBox(width: 10),
                  _OutlineButton(label: 'Delete', icon: Icons.delete_outline, onTap: onDelete),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PinkButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.blushPink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.small.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.secondaryText, size: 14),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.small.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
