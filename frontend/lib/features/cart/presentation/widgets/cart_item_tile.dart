import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/cart_item_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;
  final void Function(int) onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.softWhite,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.primaryImage != null
                ? Image.network(
                    item.primaryImage!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _imgPlaceholder(),
                  )
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: AppTextStyles.productName.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (item.color.isNotEmpty)
                  Text(item.color, style: AppTextStyles.small),
                Text('Size : ${item.size}', style: AppTextStyles.small),
                const SizedBox(height: 6),
                Text(_formatRupiah(item.lineTotal),
                    style: AppTextStyles.type.copyWith(color: AppColors.blushPink)),
                const SizedBox(height: 8),
                // Qty controls
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      onTap: item.quantity > 1
                          ? () => onQuantityChanged(item.quantity - 1)
                          : onRemove,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('${item.quantity}', style: AppTextStyles.type),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      onTap: () => onQuantityChanged(item.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.close_rounded, size: 18, color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.roseMist,
      child: const Icon(Icons.image_outlined, color: AppColors.blushPink),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          color: AppColors.softWhite,
        ),
        child: Icon(icon, size: 16, color: AppColors.primaryText),
      ),
    );
  }
}
