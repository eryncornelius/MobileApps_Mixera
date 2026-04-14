import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_balance_card.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walletC = Get.find<WalletController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.blushPink,
          onRefresh: walletC.refresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 14),
              _buildHeader(context),
              const SizedBox(height: 28),
              Obx(() {
                if (walletC.isLoadingWallet.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(color: AppColors.blushPink),
                    ),
                  );
                }
                final balance = walletC.wallet.value?.balance ?? 0;
                return WalletBalanceCard(
                  balance: balance,
                  onAddMoney: () =>
                      Navigator.pushNamed(context, RouteNames.addMoney),
                );
              }),
              const SizedBox(height: 28),
              Text('Payment methods', style: AppTextStyles.section),
              const SizedBox(height: 12),
              Obx(() {
                if (walletC.isLoadingCards.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(color: AppColors.blushPink),
                    ),
                  );
                }
                final cards = walletC.savedCards;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.softWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: cards.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'No saved cards yet. Tap Add Money to add one.',
                            style: AppTextStyles.description,
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < cards.length; i++) ...[
                              _SavedCardTile(
                                onTap: () => walletC.setDefaultCard(cards[i].id),
                                label: cards[i].displayLabel,
                                expiry: cards[i].expiryLabel,
                                isDefault: cards[i].isDefault,
                              ),
                              if (i != cards.length - 1)
                                const Divider(height: 1, color: AppColors.border),
                            ],
                          ],
                        ),
                );
              }),
              const SizedBox(height: 28),
              Text('Transaction History', style: AppTextStyles.section),
              const SizedBox(height: 12),
              Obx(() {
                if (walletC.isLoadingTransactions.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(color: AppColors.blushPink),
                    ),
                  );
                }
                final txs = walletC.transactions;
                if (txs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No transactions yet.',
                        style: AppTextStyles.description,
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: txs.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) => TransactionTile(tx: txs[i]),
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 20),
        Text('Wallet', style: AppTextStyles.headline),
        const SizedBox(height: 4),
        Text('Manage your balance & payments',
            style: AppTextStyles.description),
      ],
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({
    required this.onTap,
    required this.label,
    required this.expiry,
    required this.isDefault,
  });

  final VoidCallback onTap;
  final String label;
  final String expiry;
  final bool isDefault;

  String get _brand {
    final raw = label.split(' ').first.trim().toUpperCase();
    if (raw.contains('VISA')) return 'VISA';
    if (raw.contains('MASTERCARD') || raw.contains('MASTER')) return 'MASTERCARD';
    return 'CARD';
  }

  Widget _buildBrandBadge() {
    if (_brand == 'VISA') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFCFE0FF)),
        ),
        child: const Text(
          'VISA',
          style: TextStyle(
            color: Color(0xFF2046A9),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
      );
    }
    if (_brand == 'MASTERCARD') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5F00),
              shape: BoxShape.circle,
            ),
          ),
          Transform.translate(
            offset: const Offset(-4, 0),
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB800),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }
    return const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.secondaryText);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildBrandBadge(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.productName.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isDefault)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.roseMist,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Default',
                    style: AppTextStyles.small.copyWith(color: AppColors.blushPink),
                  ),
                ),
              if (expiry.isNotEmpty)
                Text(
                  expiry,
                  style: AppTextStyles.small,
                ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
