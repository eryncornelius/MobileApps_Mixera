import 'dart:async';

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
enum Card3DSResult { success, pending, failed, cancelled, staleRedirect }

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
  bool _popped = false;

  Timer? _statusTimer;
  int _statusPollCount = 0;
  static const int _maxBackgroundPolls = 120;

  final _ds = CardPaymentRemoteDatasource();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: _onPageFinished,
        onNavigationRequest: _onNavigate,
      ))
      ..loadRequest(Uri.parse(widget.args.redirectUrl));

    // 3DS2 / sandbox sering tidak redirect ke mixera:// — polling status tetap jalan.
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_pollMidtransStatus(background: true));
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _safePop(Card3DSResult result) {
    if (!mounted || _popped) return;
    _popped = true;
    _statusTimer?.cancel();
    Navigator.pop(context, result);
  }

  Future<void> _pollMidtransStatus({required bool background}) async {
    if (!mounted || _popped) return;
    if (_polling && background) return;

    if (background) {
      _statusPollCount++;
      if (_statusPollCount > _maxBackgroundPolls) {
        _statusTimer?.cancel();
        if (mounted && !_popped && !_polling) {
          _safePop(Card3DSResult.pending);
        }
        return;
      }
    }

    try {
      final status =
          await _ds.getTransactionStatus(widget.args.midtransOrderId);
      final tx = status['transaction_status'] as String? ?? 'pending';
      final fraud = status['fraud_status'] as String? ?? '';

      if ((tx == 'capture' || tx == 'settlement') &&
          (fraud == 'accept' || fraud.isEmpty)) {
        if (background) {
          if (mounted) setState(() => _polling = true);
        }
        _safePop(Card3DSResult.success);
        return;
      }
      if (tx == 'deny' ||
          tx == 'failure' ||
          tx == 'cancel' ||
          tx == 'expire') {
        _safePop(Card3DSResult.failed);
      }
    } catch (_) {
      // abaikan — percobaan berikutnya
    }
  }

  void _onPageFinished(String url) {
    if (mounted) setState(() => _loading = false);
    if (_popped) return;

    _controller.runJavaScript('''
      (function() {
        try {
          var txt = (document.body && document.body.innerText) ? document.body.innerText : '';
          var lower = txt.toLowerCase();
          if (txt.indexOf("Transaction doesn't exist") !== -1 ||
              txt.indexOf("Transaction does not exist") !== -1) {
            window.location.href = 'mixera://3ds/stale';
            return;
          }
          if (lower.indexOf('card is authenticated') !== -1 ||
              lower.indexOf('authenticated successfully') !== -1 ||
              lower.indexOf('authentication successful') !== -1 ||
              lower.indexOf('authentication completed') !== -1 ||
              lower.indexOf('payment successful') !== -1) {
            window.location.href = 'mixera://3ds/done';
          }
        } catch(e) {}
      })();
    ''');
  }

  NavigationDecision _onNavigate(NavigationRequest req) {
    final url = req.url;
    if (url.startsWith('mixera://3ds/stale')) {
      if (!_popped && mounted) {
        _safePop(Card3DSResult.staleRedirect);
      }
      return NavigationDecision.prevent;
    }
    // Hanya deep link app — jangan anggap domain bank ACS sebagai "selesai".
    if (url.startsWith('mixera://3ds/done') || url.startsWith('mixera://')) {
      if (!_popped) unawaited(_finalizeFromRedirect());
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  /// Setelah redirect (mixera://3ds/done atau domain lain): polling singkat.
  Future<void> _finalizeFromRedirect() async {
    if (_popped) return;
    _statusTimer?.cancel();
    if (mounted) setState(() => _polling = true);

    for (var i = 0; i < 15 && mounted && !_popped; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        final status =
            await _ds.getTransactionStatus(widget.args.midtransOrderId);
        final tx = status['transaction_status'] as String? ?? 'pending';
        final fraud = status['fraud_status'] as String? ?? '';

        if ((tx == 'capture' || tx == 'settlement') &&
            (fraud == 'accept' || fraud.isEmpty)) {
          _safePop(Card3DSResult.success);
          return;
        }
        if (tx == 'deny' ||
            tx == 'failure' ||
            tx == 'cancel' ||
            tx == 'expire') {
          _safePop(Card3DSResult.failed);
          return;
        }
      } catch (_) {}
    }

    if (mounted && !_popped) {
      _safePop(Card3DSResult.pending);
    }
  }

  Future<void> _onManualDone() async {
    if (_popped || _polling) return;
    await _finalizeFromRedirect();
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => _safePop(Card3DSResult.cancelled),
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
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Jika layar bank sudah selesai tapi tidak lanjut otomatis, '
                'ketuk tombol di bawah.',
                style: AppTextStyles.small,
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
                              'Memverifikasi pembayaran…',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: (_polling || _popped) ? null : _onManualDone,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blushPink,
                    side: const BorderSide(color: AppColors.blushPink),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Sudah selesai di halaman bank',
                    style: AppTextStyles.small.copyWith(
                      color: (_polling || _popped)
                          ? AppColors.secondaryText
                          : AppColors.blushPink,
                    ),
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
