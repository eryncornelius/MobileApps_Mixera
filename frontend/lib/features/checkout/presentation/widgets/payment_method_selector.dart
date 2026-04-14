import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

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

  @override
  Widget build(BuildContext context) {
    final checkoutC = Get.find<CheckoutController>();

    return Obx(() {
      final selected = checkoutC.selectedPaymentMethod.value;
      return Column(
        children: [
          ...checkoutC.paymentMethods.map((pm) {
            final isSelected = pm.id == selected;
            return GestureDetector(
              onTap: () => checkoutC.selectedPaymentMethod.value = pm.id,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.roseMist : AppColors.softWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.blushPink : AppColors.border,
                  ),
                  boxShadow: [
                    if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.blushPink : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        pm.id == 'wallet'
                            ? Icons.account_balance_wallet_outlined
                            : Icons.credit_card_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pm.label, style: AppTextStyles.type),
                          Text(pm.description, style: AppTextStyles.small),
                          if (pm.id == 'wallet') ...[
                            const SizedBox(height: 4),
                            Obx(() {
                              final balance = checkoutC.walletBalance.value;
                              final cartTotal =
                                  Get.find<CartController>().total;
                              if (balance == null) {
                                return const SizedBox.shrink();
                              }
                              final insufficient = balance < cartTotal;
                              final formatted = _fmt(balance);
                              return Row(
                                children: [
                                  Text(
                                    'Balance: $formatted',
                                    style: AppTextStyles.small.copyWith(
                                      color: insufficient
                                          ? AppColors.error
                                          : AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (insufficient) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '· Insufficient',
                                      style: AppTextStyles.small.copyWith(
                                          color: AppColors.error),
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.blushPink, size: 20),
                  ],
                ),
              ),
            );
          }),

          // Saved cards sub-section (shown only when card is selected)
          if (selected == 'card') _SavedCardSection(),
        ],
      );
    });
  }
}

class _SavedCardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final checkoutC = Get.find<CheckoutController>();

    return Obx(() {
      if (checkoutC.isLoadingSavedCards.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.blushPink),
            ),
          ),
        );
      }

      final cards = checkoutC.savedCards;
      if (cards.isEmpty) return const SizedBox.shrink();

      final selectedId = checkoutC.selectedSavedCardId.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text('Saved Cards', style: AppTextStyles.small),
          ),
          ...cards.map((card) {
            final isCardSelected = selectedId == card.id;
            return GestureDetector(
              onTap: () => checkoutC.selectedSavedCardId.value =
                  isCardSelected ? null : card.id,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isCardSelected ? AppColors.roseMist : AppColors.softWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCardSelected ? AppColors.blushPink : AppColors.border,
                  ),
                  boxShadow: [
                    if (!isCardSelected) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card_rounded,
                      size: 20,
                      color: isCardSelected
                          ? AppColors.blushPink
                          : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(card.displayLabel, style: AppTextStyles.type),
                    ),
                    if (card.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.roseMist,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.blushPink),
                        ),
                        child: Text('Default',
                            style: AppTextStyles.small
                                .copyWith(color: AppColors.blushPink)),
                      ),
                    if (isCardSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.blushPink, size: 18),
                    ],
                  ],
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () => checkoutC.selectedSavedCardId.value = null,
            child: Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 16,
                      color: selectedId == null
                          ? AppColors.blushPink
                          : AppColors.secondaryText),
                  const SizedBox(width: 6),
                  Text(
                    'Use a new card',
                    style: AppTextStyles.small.copyWith(
                      color: selectedId == null
                          ? AppColors.blushPink
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
