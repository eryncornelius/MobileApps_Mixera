import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/wallet_controller.dart';

/// Arguments passed to this page.
class SnapWebViewArgs {
  final String snapToken;
  final String orderId;

  const SnapWebViewArgs({required this.snapToken, required this.orderId});
}

class SnapWebViewPage extends StatefulWidget {
  final SnapWebViewArgs args;
  const SnapWebViewPage({super.key, required this.args});

  @override
  State<SnapWebViewPage> createState() => _SnapWebViewPageState();
}

class _SnapWebViewPageState extends State<SnapWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _polling = false;

  static const _snapBaseUrl = 'https://app.sandbox.midtrans.com/snap/v4/redirection/';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            // Detect when Midtrans redirects away from the Snap page
            if (!req.url.contains('app.sandbox.midtrans.com') &&
                !req.url.contains('app.midtrans.com')) {
              _handlePaymentFinished();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('$_snapBaseUrl${widget.args.snapToken}'),
      );
  }

  Future<void> _handlePaymentFinished() async {
    if (_polling) return;
    setState(() => _polling = true);

    final walletC = Get.find<WalletController>();
    String status = 'pending';

    // Poll up to 5 times, 2 s apart
    for (int i = 0; i < 5; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      status = await walletC.pollStatus(widget.args.orderId);
      if (status == 'settlement' || status == 'capture') break;
    }

    if (mounted) {
      Navigator.pop(context, status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, 'cancelled'),
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
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading || _polling)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.blushPink),
                    ),
                  if (_polling)
                    Container(
                      color: Colors.black26,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: AppColors.blushPink),
                            const SizedBox(height: 16),
                            Text('Verifying payment...',
                                style: AppTextStyles.description
                                    .copyWith(color: Colors.white)),
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
