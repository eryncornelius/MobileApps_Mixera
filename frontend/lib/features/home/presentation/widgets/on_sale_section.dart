import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/dashboard_model.dart';

class OnSaleSection extends StatelessWidget {
  final List<SaleItemModel> items;
  final VoidCallback? onViewAll;
  final void Function(SaleItemModel)? onItemTap;

  const OnSaleSection({
    super.key,
    required this.items,
    this.onViewAll,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('On Sale', style: AppTextStyles.section),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all →',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.blushPink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text('Limited time offers!', style: AppTextStyles.description),
        const SizedBox(height: 14),
        // Items row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.take(3).map((item) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: item == items.last ? 0 : 10),
                child: _SaleCard(
                  item: item,
                  onTap: () => onItemTap?.call(item),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SaleCard extends StatelessWidget {
  final SaleItemModel item;
  final VoidCallback? onTap;

  const _SaleCard({required this.item, this.onTap});

  String _formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.roseMist,
                        child: const Icon(
                          Icons.checkroom_outlined,
                          color: AppColors.blushPink,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blushPink,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${item.discountPercent}%',
                      style: AppTextStyles.small.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(item.originalPrice),
                    style: AppTextStyles.small.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _formatPrice(item.salePrice),
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.blushPink,
                      fontWeight: FontWeight.w600,
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
