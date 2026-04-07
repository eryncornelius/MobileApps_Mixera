import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../checkout/data/models/order_model.dart';
import 'order_status_chip.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final OrderModel order;

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.blushPink.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: order ID + total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: AppTextStyles.productName,
                ),
                Text(
                  _fmt(order.total),
                  style: AppTextStyles.productName.copyWith(
                    color: AppColors.blushPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(order.createdAt),
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 10),
            // Content row: thumbnail + status + button
            Row(
              children: [
                // Product thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: firstItem != null && firstItem.primaryImage.isNotEmpty
                      ? Image.network(
                          firstItem.primaryImage,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 12),
                // Status chip
                Expanded(
                  child: OrderStatusChip(status: order.status),
                ),
                // View Order button
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouteNames.orderDetail,
                    arguments: order.id,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.roseMist,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.blushPink.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'View Order',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.roseMist,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_outlined, color: AppColors.blushPink, size: 22),
    );
  }
}
