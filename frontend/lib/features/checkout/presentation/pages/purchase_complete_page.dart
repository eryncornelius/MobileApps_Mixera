import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/checkout_controller.dart';

class PurchaseCompletePage extends StatelessWidget {
  const PurchaseCompletePage({super.key});

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
    final order = Get.find<CheckoutController>().lastOrder.value;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'MIXÉRA',
                  style: AppTextStyles.logo
                      .copyWith(color: AppColors.blushPink, letterSpacing: 2),
                ),
              ),
              const Spacer(),
              // Success icon
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.roseMist,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.blushPink, size: 44),
              ),
              const SizedBox(height: 24),
              Text('Order Placed!', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              if (order != null) ...[
                Text(
                  'Order #${order.id} · ${_fmt(order.total)}',
                  style: AppTextStyles.description,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status == 'processing' ? 'Processing' : order.status,
                    style: AppTextStyles.small.copyWith(color: AppColors.success),
                  ),
                ),
              ] else
                Text('Your order is confirmed.', style: AppTextStyles.description),
              const SizedBox(height: 16),
              Text(
                'We\'ll notify you when your items ship.',
                style: AppTextStyles.description,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.orders,
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blushPink,
                  foregroundColor: AppColors.softWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text('View My Orders'),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.mainShell,
                  (route) => false,
                ),
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.description
                      .copyWith(color: AppColors.blushPink),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
