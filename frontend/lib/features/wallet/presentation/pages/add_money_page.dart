import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../checkout/data/datasources/card_payment_remote_datasource.dart';
import '../../../checkout/data/models/saved_card_model.dart';
import '../../../checkout/presentation/controllers/checkout_controller.dart';
import '../../../checkout/presentation/pages/card_3ds_page.dart';
import '../../../checkout/presentation/pages/card_tokenize_page.dart';
import '../controllers/wallet_controller.dart';

sealed class _CardTopUpPick {}

final class _CardTopUpPickNew extends _CardTopUpPick {}

final class _CardTopUpPickSaved extends _CardTopUpPick {
  _CardTopUpPickSaved(this.id);
  final int id;
}

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final _amountController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? _validatedTopUpAmount() {
    final raw = _amountController.text.replaceAll('.', '').trim();
    final amount = int.tryParse(raw);
    if (amount == null || amount < 10000) {
      setState(() => _errorText = 'Minimum top-up is Rp 10.000');
      return null;
    }
    setState(() => _errorText = null);
    return amount;
  }

  Future<void> _onCardTopUp() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Top-up dengan kartu hanya didukung di aplikasi mobile.'),
        ),
      );
      return;
    }

    final amount = _validatedTopUpAmount();
    if (amount == null) return;

    final cardDs = CardPaymentRemoteDatasource();
    List<SavedCardModel> cards = [];
    try {
      cards = await cardDs.getSavedCards();
    } catch (_) {
      cards = [];
    }
    if (!mounted) return;

    int? savedCardId;
    var useNewCard = cards.isEmpty;

    if (!useNewCard) {
      final pick = await showModalBottomSheet<_CardTopUpPick>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Bayar dengan kartu', style: AppTextStyles.section),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.add_card_outlined),
                title: const Text('Kartu baru'),
                onTap: () => Navigator.pop(ctx, _CardTopUpPickNew()),
              ),
              for (final c in cards)
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(c.displayLabel),
                  onTap: () => Navigator.pop(ctx, _CardTopUpPickSaved(c.id)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      );
      if (!mounted || pick == null) return;
      switch (pick) {
        case _CardTopUpPickNew():
          useNewCard = true;
        case _CardTopUpPickSaved(:final id):
          savedCardId = id;
      }
    }

    String cardToken = '';
    var saveCard = false;
    if (useNewCard) {
      final clientKey = (dotenv.env['MIDTRANS_CLIENT_KEY'] ?? '').trim();
      final isSandbox =
          dotenv.env['MIDTRANS_IS_PRODUCTION']?.toLowerCase() != 'true';
      final tokenResult = await Navigator.pushNamed<CardTokenResult?>(
        context,
        RouteNames.cardTokenize,
        arguments: CardTokenizeArgs(
          clientKey: clientKey,
          total: amount,
          isSandbox: isSandbox,
        ),
      );
      if (!mounted || tokenResult == null) return;
      cardToken = tokenResult.tokenId;
      saveCard = tokenResult.saveCard;
    }

    final walletC = Get.find<WalletController>();
    var chargeResult = await walletC.chargeWalletWithCard(
      amount: amount,
      cardToken: cardToken,
      savedCardId: savedCardId,
      saveCard: saveCard,
    );
    if (!mounted) return;
    if (chargeResult == null) return;

    var didRetryThreeDs = false;
    while (chargeResult != null && chargeResult.needs3DS) {
      final dsResult = await Navigator.pushNamed<Card3DSResult?>(
        context,
        RouteNames.card3DS,
        arguments: Card3DSArgs(
          redirectUrl: chargeResult.redirectUrl!,
          midtransOrderId: chargeResult.midtransOrderId,
        ),
      );
      if (!mounted) return;

      if (dsResult == Card3DSResult.success) {
        await walletC.refresh();
        if (Get.isRegistered<CheckoutController>()) {
          await Get.find<CheckoutController>().refreshWalletBalance();
        }
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _SuccessDialog(amount: amount),
        );
        return;
      }
      if (dsResult == Card3DSResult.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran dibatalkan.'),
            backgroundColor: AppColors.secondaryText,
          ),
        );
        return;
      }
      if (dsResult == Card3DSResult.staleRedirect && !didRetryThreeDs) {
        didRetryThreeDs = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi verifikasi kedaluwarsa. Memuat halaman 3DS baru…'),
            duration: Duration(seconds: 3),
          ),
        );
        chargeResult = await walletC.chargeWalletWithCard(
          amount: amount,
          cardToken: cardToken,
          savedCardId: savedCardId,
          saveCard: saveCard,
          retryThreeDs: true,
        );
        if (!mounted) return;
        if (chargeResult == null) return;
        continue;
      }
      if (dsResult == Card3DSResult.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran ditolak setelah verifikasi.'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      if (dsResult == Card3DSResult.pending) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Status belum pasti. Saldo akan terisi jika pembayaran berhasil.',
            ),
            backgroundColor: AppColors.secondaryText,
          ),
        );
        return;
      }
      return;
    }

    if (chargeResult != null && chargeResult.isSuccess) {
      await walletC.refresh();
      if (Get.isRegistered<CheckoutController>()) {
        await Get.find<CheckoutController>().refreshWalletBalance();
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(amount: amount),
      );
    } else if (chargeResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran tidak selesai.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletC = Get.find<WalletController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              _buildHeader(context),
              const SizedBox(height: 28),
              // Amount input card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How much would you like to add?',
                        style: AppTextStyles.description),
                    const SizedBox(height: 12),
                    _AmountField(
                      controller: _amountController,
                      errorText: _errorText,
                      onChanged: (_) {
                        if (_errorText != null) {
                          setState(() => _errorText = null);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Metode pembayaran',
                style: AppTextStyles.description,
              ),
              const SizedBox(height: 12),
              Obx(() {
                final busy = walletC.isCreatingTransaction.value;
                return ElevatedButton(
                  onPressed: busy ? null : _onCardTopUp,
                  child: busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kartu debit / kredit (termasuk tersimpan)'),
                );
              }),
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
        Text('Add Money', style: AppTextStyles.headline),
      ],
    );
  }
}

class _AmountField extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _AmountField({
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandSeparatorFormatter(),
      ],
      style: AppTextStyles.headline.copyWith(fontSize: 22),
      decoration: InputDecoration(
        prefixText: 'Rp ',
        prefixStyle: AppTextStyles.headline.copyWith(fontSize: 22),
        errorText: widget.errorText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blushPink, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: widget.onChanged,
    );
  }
}

/// Formats digits as thousands-separated (e.g. 600000 → "600.000")
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
      count++;
    }
    final formatted = buffer.toString().split('').reversed.join();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final int amount;

  const _SuccessDialog({required this.amount});

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.roseMist,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.blushPink, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Transaction Successful', style: AppTextStyles.section),
            const SizedBox(height: 8),
            Text(
              '${_formatRupiah(amount)} has been added to your account',
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // back to wallet page
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
