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
