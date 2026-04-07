import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class CardTokenizeArgs {
  final String clientKey;
  final int total;
  final bool isSandbox;

  const CardTokenizeArgs({
    required this.clientKey,
    required this.total,
    this.isSandbox = true,
  });
}

class CardTokenResult {
  final String tokenId;
  final bool saveCard;

  const CardTokenResult({required this.tokenId, required this.saveCard});
}

// Formats card number with spaces every 4 digits (max 16 digits).
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class CardTokenizePage extends StatefulWidget {
  final CardTokenizeArgs args;
  const CardTokenizePage({super.key, required this.args});

  @override
  State<CardTokenizePage> createState() => _CardTokenizePageState();
}

class _CardTokenizePageState extends State<CardTokenizePage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _expMonthCtrl = TextEditingController();
  final _expYearCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _saveCard = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expMonthCtrl.dispose();
    _expYearCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _tokenize() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final baseUrl = widget.args.isSandbox
        ? 'https://api.sandbox.midtrans.com'
        : 'https://api.midtrans.com';

    // Midtrans client-side tokenization — card data goes directly to Midtrans,
    // never through the merchant backend.
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '$baseUrl/v2/token',
        queryParameters: {
          'card_number': _cardNumberCtrl.text.replaceAll(' ', ''),
          'card_exp_month': _expMonthCtrl.text.trim(),
          'card_exp_year': _expYearCtrl.text.trim(),
          'card_cvv': _cvvCtrl.text.trim(),
          'client_key': widget.args.clientKey,
        },
      );
      final data = response.data;
      if (data != null && data['status_code'] == '200') {
        final result = CardTokenResult(
          tokenId: data['token_id'] as String,
          saveCard: _saveCard,
        );
        if (mounted) Navigator.pop(context, result);
      } else {
        setState(() {
          _error = (data?['status_message'] as String?) ?? 'Tokenization failed.';
        });
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? e.response!.data['status_message'] as String?
          : null;
      setState(() {
        _error = serverMsg ?? 'Network error. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        size: 24, color: AppColors.primaryText),
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
                  const SizedBox(width: 24),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Card Details', style: AppTextStyles.headline),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your card data is never stored on our servers.',
                style: AppTextStyles.small,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Card Number'),
                      _CardField(
                        controller: _cardNumberCtrl,
                        hint: '0000 0000 0000 0000',
                        inputFormatters: [_CardNumberFormatter()],
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.creditCardNumber],
                        validator: (v) {
                          final digits = (v ?? '').replaceAll(' ', '');
                          if (digits.length < 12) return 'Enter a valid card number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Month'),
                                _CardField(
                                  controller: _expMonthCtrl,
                                  hint: 'MM',
                                  maxLength: 2,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [
                                    AutofillHints.creditCardExpirationMonth
                                  ],
                                  validator: (v) {
                                    final n = int.tryParse(v?.trim() ?? '');
                                    if (n == null || n < 1 || n > 12) {
                                      return 'MM';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Year'),
                                _CardField(
                                  controller: _expYearCtrl,
                                  hint: 'YYYY',
                                  maxLength: 4,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [
                                    AutofillHints.creditCardExpirationYear
                                  ],
                                  validator: (v) {
                                    if ((v?.trim().length ?? 0) != 4) return 'YYYY';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('CVV'),
                                _CardField(
                                  controller: _cvvCtrl,
                                  hint: 'CVV',
                                  maxLength: 4,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [
                                    AutofillHints.creditCardSecurityCode
                                  ],
                                  validator: (v) {
                                    if ((v?.trim().length ?? 0) < 3) return 'CVV';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _saveCard = !_saveCard),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _saveCard,
                              onChanged: (v) =>
                                  setState(() => _saveCard = v ?? false),
                              activeColor: AppColors.blushPink,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            const SizedBox(width: 4),
                            const Text('Save card for future purchases',
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _tokenize,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blushPink,
                            disabledBackgroundColor:
                                AppColors.blushPink.withValues(alpha: 0.55),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Tokenize Card',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFFE07A7A)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF6B6B6B),
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  const _CardField({
    required this.controller,
    required this.hint,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.autofillHints,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (inputFormatters != null) ...inputFormatters!,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      autofillHints: autofillHints,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2E2E2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFBDBDBD), fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.blushPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE07A7A), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE07A7A), width: 1.5),
        ),
        counterText: '',
      ),
    );
  }
}
