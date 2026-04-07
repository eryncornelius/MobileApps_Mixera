import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/order_status_model.dart';
import '../controllers/orders_controller.dart';
import '../widgets/order_tile.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo
            Text(
              'MIXÉRA',
              style: AppTextStyles.logo.copyWith(
                color: AppColors.blushPink,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            // Main white card
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blushPink.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text('Orders', style: AppTextStyles.headline),
                    const SizedBox(height: 20),
                    // Tab bar
                    Obx(() => _TabBar(
                          selected: controller.selectedTab.value,
                          onSelect: controller.selectTab,
                        )),
                    const SizedBox(height: 16),
                    // Content
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.blushPink,
                              strokeWidth: 2,
                            ),
                          );
                        }

                        if (controller.errorMessage.value != null) {
                          return _ErrorState(
                            message: controller.errorMessage.value!,
                            onRetry: controller.fetchOrders,
                          );
                        }

                        final items = controller.filteredOrders;
                        if (items.isEmpty) {
                          return _EmptyState(tab: controller.selectedTab.value);
                        }

                        return RefreshIndicator(
                          color: AppColors.blushPink,
                          onRefresh: controller.fetchOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: items.length,
                            itemBuilder: (_, i) => OrderTile(order: items[i]),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selected, required this.onSelect});

  final OrderTab selected;
  final void Function(OrderTab) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.warmCream,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: OrderTab.values.map((tab) {
            final isSelected = tab == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blushPink : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tab.label,
                    style: AppTextStyles.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.softWhite : AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});

  final OrderTab tab;

  @override
  Widget build(BuildContext context) {
    final messages = {
      OrderTab.ongoing: ('No active orders', 'Your ongoing orders will appear here.'),
      OrderTab.delivered: ('No delivered orders', 'Completed orders will appear here.'),
      OrderTab.cancelled: ('No cancelled orders', "You haven't cancelled any orders."),
    };
    final (title, subtitle) = messages[tab]!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.roseMist,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.blushPink,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.section),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: AppTextStyles.description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try again',
                style: AppTextStyles.description.copyWith(color: AppColors.blushPink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
