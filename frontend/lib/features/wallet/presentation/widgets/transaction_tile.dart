import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../data/models/wallet_transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransactionModel tx;

  const TransactionTile({super.key, required this.tx});

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isTopUp = tx.isTopUp;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isTopUp
                  ? AppColors.roseMist
                  : AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTopUp ? Icons.add_rounded : Icons.remove_rounded,
              color: isTopUp ? AppColors.blushPink : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? (isTopUp ? 'Top Up' : 'Deduction'),
                  style: AppTextStyles.productName,
                ),
                const SizedBox(height: 2),
                Text(_formatDate(tx.createdAt), style: AppTextStyles.small),
              ],
            ),
          ),
          Text(
            '${isTopUp ? '+' : '-'}${_formatRupiah(tx.amount)}',
            style: AppTextStyles.productName.copyWith(
              color: isTopUp ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
