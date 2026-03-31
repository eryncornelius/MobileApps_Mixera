import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class CardTokenizeArgs {
  final String clientKey;
  final int total;
  final bool isSandbox;
  // When set, the page re-tokenizes a saved card (two-click flow).
  final String? savedTokenId;

  const CardTokenizeArgs({
    required this.clientKey,
    required this.total,
    this.isSandbox = true,
    this.savedTokenId,
  });
}

class CardTokenResult {
  final String tokenId;
  final bool saveCard;

  const CardTokenResult({required this.tokenId, required this.saveCard});
}

class CardTokenizePage extends StatefulWidget {
  final CardTokenizeArgs args;
  const CardTokenizePage({super.key, required this.args});

  @override
  State<CardTokenizePage> createState() => _CardTokenizePageState();
}

class _CardTokenizePageState extends State<CardTokenizePage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('FlutterMidtrans', onMessageReceived: _onToken)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadHtmlString(_buildHtml());
  }

  void _onToken(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    if (data['success'] == true) {
      final result = CardTokenResult(
        tokenId: data['token_id'] as String,
        saveCard: data['save_card'] as bool? ?? false,
      );
      if (mounted) Navigator.pop(context, result);
    }
  }

  String _buildHtml() {
    final env = widget.args.isSandbox ? 'sandbox' : 'production';
    final jsUrl = widget.args.isSandbox
        ? 'https://api.sandbox.midtrans.com/v2/assets/js/midtrans-new-3ds.min.js'
        : 'https://api.midtrans.com/v2/assets/js/midtrans-new-3ds.min.js';
    final clientKey = widget.args.clientKey;
    final savedToken = widget.args.savedTokenId ?? '';
    final isSavedCard = savedToken.isNotEmpty;

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Card Payment</title>
  <script src="$jsUrl"
    data-environment="$env"
    data-client-key="$clientKey">
  </script>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    body { background: #FFF5F7; min-height: 100vh; padding: 20px 16px 32px; }
    .card { background: #FFFFFF; border-radius: 16px; padding: 20px; border: 1px solid #E6E6E6; }
    .field-label { font-size: 11px; color: #6B6B6B; text-transform: uppercase; letter-spacing: 0.5px; display: block; margin-bottom: 6px; margin-top: 14px; }
    .field-label:first-child { margin-top: 0; }
    input[type=tel] {
      width: 100%; padding: 13px 14px; font-size: 15px;
      border: 1.5px solid #E6E6E6; border-radius: 10px;
      color: #2E2E2E; background: #FAFAFA; outline: none;
      -webkit-appearance: none;
    }
    input[type=tel]:focus { border-color: #F4B6C2; background: #FFF; }
    .row { display: flex; gap: 10px; }
    .row .col { flex: 1; }
    .check-row { display: flex; align-items: center; gap: 10px; margin-top: 16px; cursor: pointer; }
    .check-row input[type=checkbox] { width: 18px; height: 18px; accent-color: #F4B6C2; cursor: pointer; flex-shrink: 0; }
    .check-row span { font-size: 13px; color: #2E2E2E; }
    .saved-card-label { font-size: 14px; color: #2E2E2E; margin-bottom: 12px; }
    .saved-card-note { font-size: 12px; color: #6B6B6B; margin-bottom: 16px; }
    .pay-btn {
      width: 100%; margin-top: 20px; padding: 14px;
      background: #F4B6C2; border: none; border-radius: 30px;
      font-size: 15px; font-weight: 600; color: #fff;
      cursor: pointer; letter-spacing: 0.3px;
    }
    .pay-btn:disabled { opacity: 0.55; cursor: not-allowed; }
    .error-msg { margin-top: 10px; font-size: 12px; color: #E07A7A; text-align: center; min-height: 16px; }
    .loader-msg { margin-top: 10px; font-size: 13px; color: #6B6B6B; text-align: center; display: none; }
    .loader-msg.visible { display: block; }
  </style>
</head>
<body>
  <div class="card">
    ${isSavedCard ? '''
      <p class="saved-card-label">Paying with saved card</p>
      <p class="saved-card-note">We will re-verify your card securely via Midtrans.</p>
    ''' : '''
      <span class="field-label">Card Number</span>
      <input type="tel" id="card_number" placeholder="0000 0000 0000 0000" maxlength="19" inputmode="numeric" autocomplete="cc-number">
      <div class="row" style="margin-top:0;">
        <div class="col">
          <span class="field-label">Month</span>
          <input type="tel" id="exp_month" placeholder="MM" maxlength="2" inputmode="numeric" autocomplete="cc-exp-month">
        </div>
        <div class="col">
          <span class="field-label">Year</span>
          <input type="tel" id="exp_year" placeholder="YYYY" maxlength="4" inputmode="numeric" autocomplete="cc-exp-year">
        </div>
        <div class="col">
          <span class="field-label">CVV</span>
          <input type="tel" id="cvv" placeholder="CVV" maxlength="4" inputmode="numeric" autocomplete="cc-csc">
        </div>
      </div>
      <label class="check-row">
        <input type="checkbox" id="save_card">
        <span>Save card for future purchases</span>
      </label>
    '''}

    <button class="pay-btn" type="button" id="payBtn" onclick="tokenize()">
      ${isSavedCard ? 'Confirm Payment' : 'Tokenize Card'}
    </button>
    <div class="error-msg" id="errorMsg"></div>
    <div class="loader-msg" id="loaderMsg">Verifying card details...</div>
  </div>

  <script>
    ${isSavedCard ? '' : '''
    document.getElementById('card_number').addEventListener('input', function(e) {
      var v = e.target.value.replace(/\\D/g, '').substring(0, 16);
      var parts = [];
      for (var i = 0; i < v.length; i += 4) parts.push(v.substring(i, i + 4));
      e.target.value = parts.join(' ');
    });
    '''}

    function tokenize() {
      var btn = document.getElementById('payBtn');
      var errorEl = document.getElementById('errorMsg');
      var loaderEl = document.getElementById('loaderMsg');
      errorEl.textContent = '';

      ${isSavedCard ? '''
      var cardData = { saved_token_id: '$savedToken' };
      var saveCard = false;
      ''' : '''
      var cardNumber = document.getElementById('card_number').value.replace(/\\s/g, '');
      var expMonth   = document.getElementById('exp_month').value.trim();
      var expYear    = document.getElementById('exp_year').value.trim();
      var cvv        = document.getElementById('cvv').value.trim();
      var saveCard   = document.getElementById('save_card').checked;

      if (cardNumber.length < 12) { errorEl.textContent = 'Please enter a valid card number.'; return; }
      if (expMonth.length !== 2 || parseInt(expMonth) < 1 || parseInt(expMonth) > 12)
        { errorEl.textContent = 'Please enter a valid expiry month (MM).'; return; }
      if (expYear.length !== 4) { errorEl.textContent = 'Please enter a valid expiry year (YYYY).'; return; }
      if (cvv.length < 3) { errorEl.textContent = 'Please enter a valid CVV.'; return; }

      var cardData = { card_number: cardNumber, card_exp_month: expMonth,
                       card_exp_year: expYear, card_cvv: cvv };
      '''}

      btn.disabled = true;
      loaderEl.className = 'loader-msg visible';

      MidtransNew.getCardToken(cardData, function(response) {
        btn.disabled = false;
        loaderEl.className = 'loader-msg';
        if (response.status_code === '200') {
          FlutterMidtrans.postMessage(JSON.stringify({
            success: true,
            token_id: response.token_id,
            save_card: saveCard
          }));
        } else {
          errorEl.textContent = response.status_message || 'Tokenization failed.';
        }
      }, function(error) {
        btn.disabled = false;
        loaderEl.className = 'loader-msg';
        errorEl.textContent = (error && error.status_message)
          ? error.status_message : 'Card error. Please check your details.';
      });
    }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final isSavedCard = widget.args.savedTokenId != null;
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isSavedCard ? 'Confirm Payment' : 'Card Details',
                  style: AppTextStyles.headline,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (!isSavedCard)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your card data is never stored on our servers.',
                    style: AppTextStyles.small,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.blushPink),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
