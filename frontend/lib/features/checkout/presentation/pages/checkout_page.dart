import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/address_selector.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_selector.dart';
import 'card_3ds_page.dart';
import 'card_tokenize_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutC = Get.find<CheckoutController>();
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Checkout', style: AppTextStyles.headline),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final items = cartC.items;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Text('Items in your bag', style: AppTextStyles.section),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.softWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item.primaryImage != null
                                      ? Image.network(
                                          item.primaryImage!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) =>
                                              _imgPlaceholder(),
                                        )
                                      : _imgPlaceholder(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName,
                                          style: AppTextStyles.productName
                                              .copyWith(fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      if (item.color.isNotEmpty)
                                        Text(item.color, style: AppTextStyles.small),
                                      Text('Size : ${item.size}',
                                          style: AppTextStyles.small),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_fmt(item.lineTotal),
                                        style: AppTextStyles.type
                                            .copyWith(color: AppColors.blushPink)),
                                    Text('x${item.quantity}',
                                        style: AppTextStyles.small),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Shipping Address', style: AppTextStyles.section),
                    const SizedBox(height: 10),
                    const AddressSelector(),
                    const SizedBox(height: 24),

                    Text('Payment Method', style: AppTextStyles.section),
                    const SizedBox(height: 10),
                    const PaymentMethodSelector(),
                    const SizedBox(height: 24),

                    OrderSummaryCard(subtotal: cartC.total),
                    const SizedBox(height: 24),

                    // Confirm & Pay button
                    Obx(() {
                      final busy = checkoutC.isPlacingOrder.value ||
                          checkoutC.isChargingCard.value;
                      return ElevatedButton(
                        onPressed: busy
                            ? null
                            : () => _confirmAndPay(context, checkoutC),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Confirm & Pay'),
                      );
                    }),
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndPay(
      BuildContext context, CheckoutController checkoutC) async {
    final method = checkoutC.selectedPaymentMethod.value;

    if (method == 'wallet') {
      final success = await checkoutC.placeOrder();
      if (!context.mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, RouteNames.purchaseComplete);
      } else {
        _showError(context, checkoutC.errorMessage);
      }
    } else {
      await _handleCardPayment(context, checkoutC);
    }
  }

  Future<void> _handleCardPayment(
      BuildContext context, CheckoutController checkoutC) async {
    if (kIsWeb) {
      _showError(context, 'Card payment via browser is not supported. Please use the mobile app.');
      return;
    }

    // Step 1: Create unpaid order
    final order = await checkoutC.createCardOrder();
    if (!context.mounted) return;
    if (order == null) {
      _showError(context, checkoutC.errorMessage);
      return;
    }

    // Step 2: Tokenize (new card only) or skip to charge (saved card)
    final savedCardId = checkoutC.selectedSavedCardId.value;
    String cardToken = '';
    bool saveCard = false;

    if (savedCardId == null) {
      // New card — open tokenize form
      final tokenResult = await Navigator.pushNamed<CardTokenResult?>(
        context,
        RouteNames.cardTokenize,
        arguments: CardTokenizeArgs(
          clientKey: checkoutC.midtransClientKey,
          total: order.total,
        ),
      );

      if (!context.mounted) return;

      if (tokenResult == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled. Your order was not charged.'),
            backgroundColor: AppColors.secondaryText,
          ),
        );
        return;
      }

      cardToken = tokenResult.tokenId;
      saveCard = tokenResult.saveCard;
    }
    // Saved card — backend resolves saved_token_id from savedCardId directly.

    // Step 3: Charge
    final chargeResult = await checkoutC.chargeCardRaw(
      orderId: order.id,
      cardToken: cardToken,
      savedCardId: savedCardId,
      saveCard: saveCard,
    );
    if (!context.mounted) return;

    if (chargeResult == null) {
      _showError(context, checkoutC.errorMessage);
      return;
    }

    // Step 4: 3DS if required
    if (chargeResult.needs3DS) {
      final dsResult = await Navigator.pushNamed<Card3DSResult?>(
        context,
        RouteNames.card3DS,
        arguments: Card3DSArgs(
          redirectUrl: chargeResult.redirectUrl!,
          midtransOrderId: chargeResult.midtransOrderId,
        ),
      );
      if (!context.mounted) return;

      if (dsResult == Card3DSResult.success) {
        checkoutC.clearCardOrder();
        checkoutC.loadSavedCards(); // Reload after 3DS — backend saved the card by now
        Navigator.pushReplacementNamed(context, RouteNames.purchaseComplete);
      } else if (dsResult == Card3DSResult.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled. Your order was not charged.'),
            backgroundColor: AppColors.secondaryText,
          ),
        );
      } else {
        _showError(context, 'Card authentication failed. Please try again.');
      }
      return;
    }

    // No 3DS needed — immediate capture/settlement
    if (chargeResult.isSuccess) {
      checkoutC.clearCardOrder();
      Navigator.pushReplacementNamed(context, RouteNames.purchaseComplete);
    } else {
      _showError(context, 'Card payment was declined. Please try a different card.');
    }
  }

  void _showError(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Checkout failed. Please try again.'),
        backgroundColor: AppColors.error,
      ),
    );
  }

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

  Widget _imgPlaceholder() => Container(
        width: 60,
        height: 60,
        color: AppColors.roseMist,
        child: const Icon(Icons.image_outlined, color: AppColors.blushPink, size: 20),
      );
}
