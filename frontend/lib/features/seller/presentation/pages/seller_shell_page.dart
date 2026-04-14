import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/seller_controller.dart';
import 'seller_add_product_page.dart';
import 'seller_edit_product_page.dart';
import 'seller_channels_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SellerController>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        title: Text('Seller', style: AppTextStyles.headline.copyWith(fontSize: 18)),
        actions: [
          Obx(() {
            final n = Get.find<SellerController>().dashboard.value?['unread_notifications'] as int? ?? 0;
            return IconButton(
              tooltip: 'Notifikasi',
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerNotificationsPage()),
                ).then((_) => Get.find<SellerController>().loadDashboard());
              },
              icon: Badge(
                isLabelVisible: n > 0,
                label: Text('$n', style: const TextStyle(fontSize: 10)),
                child: const Icon(Icons.notifications_outlined, color: AppColors.secondaryText),
              ),
            );
          }),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.mainShell,
                (route) => false,
              );
            },
            child: Text(
              'Mode pembeli',
              style: AppTextStyles.small.copyWith(color: AppColors.blushPink),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _DashboardTab(c: c),
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
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Pesanan'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Saldo'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  final SellerController c;
  const _DashboardTab({required this.c});

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

  Future<void> _saveStore() async {
    final t = _storeCtrl.text.trim();
    final pc = _postalCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (pc.isNotEmpty && pc.length < 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode pos asal kirim harus 5 digit atau kosongkan.')),
        );
      }
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
          padding: const EdgeInsets.all(24),
          children: [
            Text('Nama toko', style: AppTextStyles.section),
            const SizedBox(height: 8),
            if (c.isLoadingMe.value)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: AppColors.blushPink)),
              )
            else ...[
              TextField(
                controller: _storeCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nama toko',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              Text('Kode pos asal kirim', style: AppTextStyles.section),
              const SizedBox(height: 8),
              Text(
                'Digunakan untuk hitung ongkir ke pembeli (Biteship). Kosongkan untuk pakai kode pos default server.',
                style: AppTextStyles.small,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _postalCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: const InputDecoration(
                  hintText: 'Contoh: 40123',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _savingStore ? null : _saveStore,
                  child: _savingStore
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blushPink),
                        )
                      : Text('Simpan', style: AppTextStyles.small.copyWith(color: AppColors.blushPink)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text('Ringkas', style: AppTextStyles.section),
            const SizedBox(height: 8),
            Obx(() {
              final d = c.dashboard.value;
              if (c.isLoadingDashboard.value && d == null) {
                return Text('Memuat ringkasan…', style: AppTextStyles.description);
              }
              final pc = d?['product_count'] as int? ?? c.products.length;
              final oc = d?['order_count'] as int? ?? c.orders.length;
              final completed =
                  d?['completed_count'] as int? ?? c.orders.where((o) => o['status'] == 'completed').length;
              final proc = d?['processing_count'] as int? ?? 0;
              final low = d?['low_stock_count'] as int? ?? 0;
              final bal = (d?['available_balance'] as num?)?.toInt() ?? 0;
              String rp(int v) {
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

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total',
                          value: '$oc',
                          subtitle: '$completed selesai',
                          icon: Icons.receipt_long_outlined,
                          iconColor: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Menunggu',
                          value: '$proc',
                          subtitle: 'Diproses',
                          icon: Icons.schedule,
                          iconColor: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Produk',
                          value: '$pc',
                          subtitle: '$low stok rendah',
                          icon: Icons.inventory_2_outlined,
                          iconColor: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.blushPink, AppColors.roseMist],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blushPink.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                              const SizedBox(height: 8),
                              Text('Saldo Estimasi', style: AppTextStyles.small.copyWith(color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(rp(bal), style: AppTextStyles.headline.copyWith(color: Colors.white, fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Tab Saldo: mutasi, payout. Produk & pesanan di tab terkait.',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => const SellerChannelsPage()),
                  );
                },
                icon: const Icon(Icons.hub_outlined, size: 20, color: AppColors.blushPink),
                label: Text(
                  'Saluran jualan (stub)',
                  style: AppTextStyles.small.copyWith(color: AppColors.blushPink),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.small),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headline.copyWith(fontSize: 20)),
          Text(subtitle, style: AppTextStyles.description),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final SellerController c;
  const _ProductsTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerAddProductPage()),
                );
                if (context.mounted) c.loadProducts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blushPink,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              child: const Text('Tambah produk', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (c.isLoadingProducts.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.blushPink));
            }
            if (c.products.isEmpty) {
              return RefreshIndicator(
                color: AppColors.blushPink,
                onRefresh: c.loadProducts,
                child: ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    const Center(child: Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.border)),
                    const SizedBox(height: 16),
                    Center(child: Text('Belum ada produk.', style: AppTextStyles.description)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: AppColors.blushPink,
              onRefresh: c.loadProducts,
              child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: c.products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final p = c.products[i];
                return Material(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SellerEditProductPage(product: p),
                        ),
                      );
                      if (context.mounted) c.loadProducts();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: p.primaryImage != null
                                ? Image.network(p.primaryImage!, width: 56, height: 56, fit: BoxFit.cover)
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.roseMist,
                                    child: const Icon(Icons.image_outlined, color: AppColors.blushPink),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: AppTextStyles.type, maxLines: 2, overflow: TextOverflow.ellipsis),
                                Text(
                                  'Rp ${p.displayPrice} · stok ${p.totalStock}'
                                  '${p.isActive ? '' : ' · nonaktif'}'
                                  '${p.moderationFlagged ? ' · moderasi' : ''}',
                                  style: AppTextStyles.small.copyWith(color: AppColors.blushPink),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
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
}

class _OrdersTab extends StatefulWidget {
  final SellerController c;
  const _OrdersTab({required this.c});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  /// null = semua status
  String? _statusFilter;

  String _fmt(int v) {
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

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> all) {
    if (_statusFilter == null) return all;
    return all.where((o) => o['status'] == _statusFilter).toList();
  }

  Widget _chip(String label, String? value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: AppTextStyles.small),
        selected: selected,
        onSelected: (sel) {
          setState(() {
            if (value == null) {
              _statusFilter = null;
            } else if (sel) {
              _statusFilter = value;
            }
          });
        },
        selectedColor: AppColors.roseMist,
        labelStyle: AppTextStyles.small,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Obx(() {
      if (c.isLoadingOrders.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.blushPink));
      }
      if (c.orders.isEmpty) {
        return RefreshIndicator(
          color: AppColors.blushPink,
          onRefresh: c.loadOrders,
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(child: Text('Belum ada pesanan.', style: AppTextStyles.description)),
            ],
          ),
        );
      }
      final filtered = _applyFilter(c.orders.toList());
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('Semua', null),
                _chip('Processing', 'processing'),
                _chip('Dikirim', 'shipped'),
                _chip('Selesai', 'completed'),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('Tidak ada di filter ini.', style: AppTextStyles.description),
                  )
                : RefreshIndicator(
                    color: AppColors.blushPink,
                    onRefresh: c.loadOrders,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final o = filtered[i];
                        final id = o['id'] as int;
                        final st = o['status'] as String? ?? '';
                        final total = o['total'] as int? ?? 0;
                        return ListTile(
                          tileColor: AppColors.softWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text('#$id · $st', style: AppTextStyles.type),
                          subtitle: Text(o['buyer_email'] as String? ?? '', style: AppTextStyles.small),
                          trailing: Text(_fmt(total),
                              style: AppTextStyles.small.copyWith(color: AppColors.blushPink)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SellerOrderDetailPage(orderId: id)),
                            );
                          },
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
