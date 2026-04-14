import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class CartSummarySection extends StatelessWidget {
  final int subtotal;
  final int deliveryFee;
  final int discountTotal;

  const CartSummarySection({
    super.key,
    required this.subtotal,
    this.deliveryFee = 20000,
    this.discountTotal = 0,
  });

  int get total => subtotal + deliveryFee - discountTotal;

  String _fmt(int v) {
    final str = v.toString();
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _row('Products:', _fmt(subtotal)),
          const SizedBox(height: 8),
          _row('Delivery', _fmt(deliveryFee)),
          if (discountTotal > 0) ...[
            const SizedBox(height: 8),
            _row('Discount', '-${_fmt(discountTotal)}',
                valueColor: AppColors.success),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          _row('Total', _fmt(total),
              labelStyle: AppTextStyles.type,
              valueStyle: AppTextStyles.section.copyWith(fontSize: 16, color: AppColors.blushPink)),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle ?? AppTextStyles.description),
        Text(value,
            style: valueStyle ??
                AppTextStyles.description.copyWith(
                  color: valueColor ?? AppColors.primaryText,
                )),
      ],
    );
  }
}
