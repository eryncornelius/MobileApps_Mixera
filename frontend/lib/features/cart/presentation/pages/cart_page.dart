import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_section.dart';
import '../widgets/checkout_button.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left_rounded,
                        size: 28, color: AppColors.primaryText),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'MIXÉRA',
                        style: AppTextStyles.logo
                            .copyWith(color: AppColors.blushPink, letterSpacing: 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('My Bag', style: AppTextStyles.headline),
                  const Spacer(),
                  Obx(() => Text(
                        '${cartC.itemCount} items',
                        style: AppTextStyles.description,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (cartC.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.blushPink),
                  );
                }
                if (cartC.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 64, color: AppColors.border),
                        const SizedBox(height: 16),
                        Text('Your bag is empty', style: AppTextStyles.section),
                        const SizedBox(height: 8),
                        Text('Add items you love to your bag',
                            style: AppTextStyles.description),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Continue Shopping'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.blushPink,
                  onRefresh: cartC.fetchCart,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Items
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: cartC.items.map((item) {
                            return CartItemTile(
                              item: item,
                              onRemove: () => cartC.removeItem(item.id),
                              onQuantityChanged: (q) => cartC.updateQuantity(item.id, q),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CartSummarySection(subtotal: cartC.total),
                      const SizedBox(height: 20),
                      CheckoutButton(
                        onPressed: cartC.isUpdating.value
                            ? null
                            : () => Navigator.pushNamed(context, RouteNames.checkout),
                        isLoading: cartC.isUpdating.value,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Continue Shopping',
                            style: AppTextStyles.description
                                .copyWith(color: AppColors.blushPink),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
