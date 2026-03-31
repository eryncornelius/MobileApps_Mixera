import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/datasources/card_payment_remote_datasource.dart';

class Card3DSArgs {
  final String redirectUrl;
  final String midtransOrderId;

  const Card3DSArgs({
    required this.redirectUrl,
    required this.midtransOrderId,
  });
}

/// Result returned to checkout after 3DS completes.
enum Card3DSResult { success, pending, failed, cancelled }

class Card3DSPage extends StatefulWidget {
  final Card3DSArgs args;
  const Card3DSPage({super.key, required this.args});

  @override
  State<Card3DSPage> createState() => _Card3DSPageState();
}

class _Card3DSPageState extends State<Card3DSPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _polling = false;

  final _ds = CardPaymentRemoteDatasource();

  // Midtrans 3DS pages all live under these domains.
  static const _midtransDomains = [
    'app.sandbox.midtrans.com',
    'app.midtrans.com',
    'api.sandbox.midtrans.com',
    'api.midtrans.com',
  ];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: _onNavigate,
      ))
      ..loadRequest(Uri.parse(widget.args.redirectUrl));
  }

  NavigationDecision _onNavigate(NavigationRequest req) {
    final isMidtrans =
        _midtransDomains.any((d) => req.url.contains(d));
    if (!isMidtrans && !_polling) {
      _handleAuthComplete();
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _handleAuthComplete() async {
    if (_polling) return;
    setState(() => _polling = true);

    Card3DSResult result = Card3DSResult.pending;

    // Poll up to 6 times, 2 s apart (12 s total)
    for (int i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        final status =
            await _ds.getTransactionStatus(widget.args.midtransOrderId);
        final tx = status['transaction_status'] as String? ?? 'pending';
        final fraud = status['fraud_status'] as String? ?? '';

        if ((tx == 'capture' || tx == 'settlement') &&
            (fraud == 'accept' || fraud.isEmpty)) {
          result = Card3DSResult.success;
          break;
        }
        if (tx == 'deny' || tx == 'failure' || tx == 'cancel' || tx == 'expire') {
          result = Card3DSResult.failed;
          break;
        }
      } catch (_) {
        // keep polling
      }
    }

    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, Card3DSResult.cancelled),
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
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Verify Payment', style: AppTextStyles.headline),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading && !_polling)
                    const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.blushPink),
                    ),
                  if (_polling)
                    Container(
                      color: Colors.black38,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                                color: AppColors.blushPink),
                            const SizedBox(height: 16),
                            Text(
                              'Verifying payment...',
                              style: AppTextStyles.description
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
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
