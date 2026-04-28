import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';
import '../controllers/seller_controller.dart';
import 'seller_add_product_page.dart';
import 'seller_channels_page.dart';
import 'seller_edit_product_page.dart';
import 'seller_finance_page.dart';
import 'seller_notifications_page.dart';
import 'seller_order_detail_page.dart';

class SellerShellPage extends StatefulWidget {
  const SellerShellPage({super.key});

  @override
  State<SellerShellPage> createState() => _SellerShellPageState();
}

class _SellerShellPageState extends State<SellerShellPage> {
  int _index = 0;

  void _switchTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SellerController>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        title: Obx(() => Text(
              c.storeName.value.isNotEmpty ? c.storeName.value : 'Seller',
              style: AppTextStyles.headline.copyWith(fontSize: 18),
            )),
        actions: [
          Obx(() {
            final n = c.dashboard.value?['unread_notifications'] as int? ?? 0;
            return IconButton(
              tooltip: 'Notifikasi',
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerNotificationsPage()),
                ).then((_) => c.loadDashboard());
              },
              icon: Badge(
                isLabelVisible: n > 0,
                label: Text('$n', style: const TextStyle(fontSize: 10)),
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.secondaryText),
              ),
            );
          }),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.mainShell,
              (route) => false,
            ),
            child: Text('Mode pembeli',
                style: AppTextStyles.small.copyWith(color: AppColors.blushPink)),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        sizing: StackFit.expand,
        children: [
          _DashboardTab(c: c, onSwitchTab: _switchTab),
          _ProductsTab(c: c),
          _OrdersTab(c: c),
          const SellerFinancePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.softWhite,
        indicatorColor: AppColors.roseMist,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Produk'),
          NavigationDestination(
              icon: Icon(Icons.local_shipping_outlined), label: 'Pesanan'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Saldo'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DASHBOARD TAB
// ─────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  final SellerController c;
  final void Function(int) onSwitchTab;
  const _DashboardTab({required this.c, required this.onSwitchTab});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final _storeCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  bool _syncedStore = false;
  bool _savingStore = false;

  @override
  void dispose() {
    _storeCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  String _rp(int v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(0)}rb';
    return 'Rp $v';
  }

  Future<void> _saveStore() async {
    final t = _storeCtrl.text.trim();
    final pc = _postalCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (pc.isNotEmpty && pc.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kode pos asal kirim harus 5 digit atau kosongkan.')),
      );
      return;
    }
    setState(() => _savingStore = true);
    try {
      await widget.c.saveStoreProfile(
        storeName: t,
        shipFromPostalCode: pc.length >= 5 ? pc.substring(0, 5) : '',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil toko disimpan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _savingStore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Obx(() {
      final loading = c.isLoadingMe.value;
      if (!loading && !_syncedStore) {
        _syncedStore = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _storeCtrl.text = c.storeName.value;
          _postalCtrl.text = c.shipFromPostalCode.value;
        });
      }
      return RefreshIndicator(
        color: AppColors.blushPink,
        onRefresh: c.refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const SizedBox(height: 8),

            // ── Stats grid ──
            Obx(() {
              final d = c.dashboard.value;
              final isLoading =
                  c.isLoadingDashboard.value && d == null;
              if (isLoading) {
                return const SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.blushPink, strokeWidth: 2),
                  ),
                );
              }
              final oc = d?['order_count'] as int? ?? 0;
              final proc = d?['processing_count'] as int? ?? 0;
              final pc = d?['product_count'] as int? ??
                  c.products.length;
              final low = d?['low_stock_count'] as int? ?? 0;
              final bal =
                  (d?['available_balance'] as num?)?.toInt() ?? 0;
              return Column(
                children: [
                  // 4 mini stat cards
                  Row(
                    children: [
                      Expanded(child: _MiniStat(
                        label: 'Total Order',
                        value: '$oc',
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.blushPink,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _MiniStat(
                        label: 'Diproses',
                        value: '$proc',
                        icon: Icons.schedule_rounded,
                        color: AppColors.warning,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _MiniStat(
                        label: 'Produk',
                        value: '$pc',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.accent,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _MiniStat(
                        label: 'Stok Rendah',
                        value: '$low',
                        icon: Icons.warning_amber_rounded,
                        color: low > 0
                            ? AppColors.error
                            : AppColors.secondaryText,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Saldo card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.blushPink,
                          Color(0xFFF0829A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushPink.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimasi Saldo',
                                style: AppTextStyles.small
                                    .copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _rp(bal),
                                style: AppTextStyles.headline.copyWith(
                                    color: Colors.white, fontSize: 26),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Diproses admin secara berkala',
                                style: AppTextStyles.small
                                    .copyWith(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white30, size: 48),
                      ],
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 20),

            // ── Sales chart ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Grafik Penjualan',
                          style: AppTextStyles.section
                              .copyWith(fontSize: 14)),
                      const Spacer(),
                      Text('8 minggu terakhir',
                          style: AppTextStyles.small),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final data = c.weeklyEarnings;
                    if (data.isEmpty) {
                      return SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            'Belum ada data penjualan.',
                            style: AppTextStyles.small,
                          ),
                        ),
                      );
                    }
                    return _SalesBarChart(data: data);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Quick actions ──
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_box_outlined,
                    label: 'Tambah\nProduk',
                    color: AppColors.blushPink,
                    onTap: () async {
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const SellerAddProductPage()),
                      );
                      if (context.mounted) c.loadProducts();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.local_shipping_outlined,
                    label: 'Pesanan\nMasuk',
                    color: AppColors.warning,
                    onTap: () => widget.onSwitchTab(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Tarik\nSaldo',
                    color: AppColors.success,
                    onTap: () => widget.onSwitchTab(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.hub_outlined,
                    label: 'Saluran\nJualan',
                    color: AppColors.accent,
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SellerChannelsPage()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Profil toko ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store_outlined,
                          size: 18, color: AppColors.blushPink),
                      const SizedBox(width: 6),
                      Text('Profil Toko',
                          style: AppTextStyles.section
                              .copyWith(fontSize: 14)),
                    ],
                  ),
                  if (c.isLoadingMe.value)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.blushPink,
                              strokeWidth: 2)),
                    )
                  else ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _storeCtrl,
                      style: AppTextStyles.description
                          .copyWith(color: AppColors.primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Nama toko',
                        isDense: true,
                        prefixIcon: Icon(Icons.storefront_outlined,
                            size: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _postalCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      style: AppTextStyles.description
                          .copyWith(color: AppColors.primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Kode pos asal kirim',
                        hintText: '40123',
                        isDense: true,
                        prefixIcon:
                            Icon(Icons.location_on_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Digunakan untuk kalkulasi ongkir ke pembeli.',
                      style: AppTextStyles.small,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _savingStore ? null : _saveStore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blushPink,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: _savingStore
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : Text('Simpan',
                                style: AppTextStyles.small.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// SALES BAR CHART
// ─────────────────────────────────────────────────────────────

class _SalesBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _SalesBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _BarChartPainter(data: data),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _BarChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data
        .map((e) => (e['amount'] as int? ?? 0).toDouble())
        .fold(0.0, math.max);
    final effectiveMax = maxVal < 1 ? 1.0 : maxVal;

    const labelHeight = 28.0;
    const topPad = 12.0;
    final chartHeight = size.height - labelHeight - topPad;
    const barGap = 6.0;
    final barWidth =
        (size.width - barGap * (data.length - 1)) / data.length;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final barPaint = Paint()..color = AppColors.roseMist;
    final barActivePaint = Paint()..color = AppColors.blushPink;

    // Grid lines (3 levels)
    for (int i = 1; i <= 3; i++) {
      final y = topPad + chartHeight - (chartHeight * i / 3);
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final amount = (data[i]['amount'] as int? ?? 0).toDouble();
      final label = data[i]['label'] as String? ?? '';
      final x = i * (barWidth + barGap);
      final barH = (amount / effectiveMax) * chartHeight;
      final top = topPad + chartHeight - barH;
      final isLast = i == data.length - 1;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, top, barWidth, barH),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );
      canvas.drawRRect(rect, isLast ? barActivePaint : barPaint);

      // Value on top of bar if non-zero
      if (amount > 0 && isLast) {
        final label2 = amount >= 1000000
            ? '${(amount / 1000000).toStringAsFixed(1)}jt'
            : amount >= 1000
                ? '${(amount / 1000).toStringAsFixed(0)}rb'
                : '${amount.toInt()}';
        textPainter.text = TextSpan(
          text: label2,
          style: const TextStyle(
              fontSize: 9,
              color: AppColors.blushPink,
              fontWeight: FontWeight.w600),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
              x + (barWidth - textPainter.width) / 2, top - 14),
        );
      }

      // X-axis label (only every other for 8 bars)
      if (i % 2 == 0 || i == data.length - 1) {
        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 9,
            color: isLast
                ? AppColors.blushPink
                : AppColors.secondaryText,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
          ),
        );
        textPainter.layout(maxWidth: barWidth + barGap);
        textPainter.paint(
          canvas,
          Offset(
            x + (barWidth - textPainter.width) / 2,
            size.height - labelHeight + 6,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => true;
}

// ─────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.headline
                  .copyWith(fontSize: 18, color: color)),
          Text(
            label,
            style: AppTextStyles.small
                .copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.small.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRODUCTS TAB
// ─────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  final SellerController c;
  const _ProductsTab({required this.c});

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  String _search = '';

  String _fmtRp(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    int n = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (n > 0 && n % 3 == 0) buf.write('.');
      buf.write(s[i]);
      n++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search + Add button (explicit width: Row + ElevatedButton needs bounded max width)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            width: math.max(0, MediaQuery.sizeOf(context).width - 32),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Cari produk…',
                      hintStyle: AppTextStyles.small,
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: AppColors.secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SellerAddProductPage()),
                    );
                    if (context.mounted) c.loadProducts();
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Tambah',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blushPink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    minimumSize: const Size(80, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Obx(() {
            if (c.isLoadingProducts.value) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.blushPink, strokeWidth: 2));
            }
            final filtered = c.products.where((p) {
              if (_search.isEmpty) return true;
              return p.name.toLowerCase().contains(_search);
            }).toList();

            if (filtered.isEmpty) {
              return RefreshIndicator(
                color: AppColors.blushPink,
                onRefresh: c.loadProducts,
                child: ListView(
                  children: [
                    const SizedBox(height: 80),
                    const Center(
                        child: Icon(Icons.inventory_2_outlined,
                            size: 64, color: AppColors.border)),
                    const SizedBox(height: 16),
                    Center(
                        child: Text(
                      _search.isEmpty
                          ? 'Belum ada produk.'
                          : 'Produk tidak ditemukan.',
                      style: AppTextStyles.description,
                    )),
                    const SizedBox(height: 12),
                    if (_search.isEmpty)
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SellerAddProductPage()),
                            );
                            if (context.mounted) c.loadProducts();
                          },
                          icon: const Icon(Icons.add,
                              color: AppColors.blushPink, size: 18),
                          label: Text('Tambah produk pertama',
                              style: AppTextStyles.small
                                  .copyWith(color: AppColors.blushPink)),
                        ),
                      ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.blushPink,
              onRefresh: c.loadProducts,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = filtered[i];
                  final hasDiscount = p.discountPrice != null &&
                      p.discountPrice! < p.price;
                  final stock = p.totalStock;
                  final stockColor = stock == 0
                      ? AppColors.error
                      : stock <= 5
                          ? AppColors.warning
                          : AppColors.success;
                  final stockLabel = stock == 0
                      ? 'Habis'
                      : stock <= 5
                          ? 'Stok $stock'
                          : 'Stok $stock';

                  return Material(
                    color: AppColors.softWhite,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SellerEditProductPage(product: p),
                          ),
                        );
                        if (context.mounted) c.loadProducts();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: p.primaryImage != null &&
                                          p.primaryImage!.isNotEmpty
                                      ? Image.network(
                                          resolveMediaUrl(
                                              p.primaryImage!),
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _imgPlaceholder(),
                                        )
                                      : _imgPlaceholder(),
                                ),
                                if (!p.isActive)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.4),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.visibility_off_outlined,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: AppTextStyles.type,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Price row
                                  Row(
                                    children: [
                                      Text(
                                        hasDiscount
                                            ? _fmtRp(p.discountPrice!)
                                            : _fmtRp(p.price),
                                        style: AppTextStyles.small
                                            .copyWith(
                                          color: hasDiscount
                                              ? AppColors.blushPink
                                              : AppColors.primaryText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (hasDiscount) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          _fmtRp(p.price),
                                          style: AppTextStyles.small
                                              .copyWith(
                                            decoration: TextDecoration
                                                .lineThrough,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Badges row
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _Badge(
                                        label: stockLabel,
                                        color: stockColor,
                                      ),
                                      if (!p.isActive)
                                        const _Badge(
                                          label: 'Nonaktif',
                                          color: AppColors.secondaryText,
                                        ),
                                      if (p.moderationFlagged)
                                        const _Badge(
                                          label: 'Moderasi',
                                          color: AppColors.error,
                                        ),
                                      if (hasDiscount)
                                        _Badge(
                                          label:
                                              '-${(((p.price - p.discountPrice!) / p.price) * 100).round()}%',
                                          color: AppColors.blushPink,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.secondaryText),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.roseMist,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          const Icon(Icons.image_outlined, color: AppColors.blushPink, size: 28),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ORDERS TAB
// ─────────────────────────────────────────────────────────────

class _OrdersTab extends StatefulWidget {
  final SellerController c;
  const _OrdersTab({required this.c});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String? _statusFilter;

  String _fmtRp(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    int n = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (n > 0 && n % 3 == 0) buf.write('.');
      buf.write(s[i]);
      n++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _fmtDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    const m = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Ags','Sep','Okt','Nov','Des'
    ];
    return '${dt.day} ${m[dt.month - 1]}';
  }

  Color _statusColor(String st) {
    switch (st) {
      case 'processing':
        return AppColors.warning;
      case 'shipped':
        return AppColors.accent;
      case 'delivered':
      case 'completed':
        return AppColors.success;
      case 'canceled':
      case 'cancelled':
        return AppColors.error;
      case 'pending':
        return AppColors.secondaryText;
      default:
        return AppColors.border;
    }
  }

  String _statusLabel(String st) {
    switch (st) {
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
      case 'completed':
        return 'Selesai';
      case 'canceled':
      case 'cancelled':
        return 'Dibatalkan';
      case 'pending':
        return 'Menunggu';
      default:
        return st;
    }
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    if (_statusFilter == null) return all;
    if (_statusFilter == 'delivered') {
      return all.where((o) {
        final s = o['status'] as String? ?? '';
        return s == 'delivered' || s == 'completed';
      }).toList();
    }
    return all.where((o) => o['status'] == _statusFilter).toList();
  }

  Widget _chip(String label, String? value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label,
            style: AppTextStyles.small.copyWith(
                color: selected
                    ? AppColors.blushPink
                    : AppColors.primaryText)),
        selected: selected,
        onSelected: (_) =>
            setState(() => _statusFilter = selected ? null : value),
        selectedColor: AppColors.roseMist,
        backgroundColor: AppColors.softWhite,
        side: BorderSide(
            color:
                selected ? AppColors.blushPink : AppColors.border),
        padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Obx(() {
      if (c.isLoadingOrders.value && c.orders.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(
                color: AppColors.blushPink, strokeWidth: 2));
      }

      final filtered = _filtered(c.orders.toList());

      return Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('Semua', null),
                _chip('Diproses', 'processing'),
                _chip('Dikirim', 'shipped'),
                _chip('Selesai', 'delivered'),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? RefreshIndicator(
                    color: AppColors.blushPink,
                    onRefresh: c.loadOrders,
                    child: ListView(
                      children: [
                        const SizedBox(height: 80),
                        const Center(
                            child: Icon(Icons.inbox_outlined,
                                size: 64, color: AppColors.border)),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            _statusFilter == null
                                ? 'Belum ada pesanan.'
                                : 'Tidak ada pesanan di filter ini.',
                            style: AppTextStyles.description,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.blushPink,
                    onRefresh: c.loadOrders,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final o = filtered[i];
                        final id = o['id'] as int;
                        final st = o['status'] as String? ?? '';
                        final total =
                            (o['total'] as num?)?.toInt() ?? 0;
                        final email =
                            o['buyer_email'] as String? ?? '';
                        final itemCount =
                            o['item_count'] as int? ?? 0;
                        final date = _fmtDate(
                            o['created_at'] as String?);
                        final stColor = _statusColor(st);
                        final stLabel = _statusLabel(st);

                        return Material(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      SellerOrderDetailPage(
                                          orderId: id)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset:
                                          const Offset(0, 4)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Status color bar
                                  Container(
                                    width: 4,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: stColor,
                                      borderRadius:
                                          BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Order #$id',
                                              style: AppTextStyles
                                                  .type,
                                            ),
                                            if (itemCount > 0) ...[
                                              const SizedBox(
                                                  width: 6),
                                              Text(
                                                '· $itemCount item',
                                                style: AppTextStyles
                                                    .small,
                                              ),
                                            ],
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal:
                                                          8,
                                                      vertical: 3),
                                              decoration:
                                                  BoxDecoration(
                                                color: stColor
                                                    .withValues(
                                                        alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(20),
                                              ),
                                              child: Text(
                                                stLabel,
                                                style: AppTextStyles
                                                    .small
                                                    .copyWith(
                                                  color: stColor,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email,
                                          style: AppTextStyles
                                              .small,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              _fmtRp(total),
                                              style: AppTextStyles
                                                  .type
                                                  .copyWith(
                                                color: AppColors
                                                    .blushPink,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(date,
                                                style: AppTextStyles
                                                    .small),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                      Icons.chevron_right_rounded,
                                      color:
                                          AppColors.secondaryText,
                                      size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }
}
