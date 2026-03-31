import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/wallet_controller.dart';
import 'snap_webview_page.dart';

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

  Future<void> _onContinue() async {
    final raw = _amountController.text.replaceAll('.', '').trim();
    final amount = int.tryParse(raw);

    if (amount == null || amount < 10000) {
      setState(() => _errorText = 'Minimum top-up is Rp 10.000');
      return;
    }
    setState(() => _errorText = null);

    final walletC = Get.find<WalletController>();
    final result = await walletC.createTopUp(amount);
    if (result == null) return;

    final orderId = result['order_id'] as String? ?? '';
    final snapToken = result['snap_token'] as String? ?? '';

    if (!mounted) return;

    // Launch Midtrans Snap WebView and wait for the payment result
    final status = await Navigator.pushNamed(
      context,
      RouteNames.snapWebView,
      arguments: SnapWebViewArgs(snapToken: snapToken, orderId: orderId),
    );

    if (!mounted) return;

    if (status == 'settlement' || status == 'capture') {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(amount: amount),
      );
    } else if (status != 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'pending'
                ? 'Payment is being processed. Your wallet will update shortly.'
                : 'Payment was not completed.',
          ),
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
              const SizedBox(height: 28),
              Obx(() => ElevatedButton(
                    onPressed: walletC.isCreatingTransaction.value
                        ? null
                        : _onContinue,
                    child: walletC.isCreatingTransaction.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Continue'),
                  )),
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
