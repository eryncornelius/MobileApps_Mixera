import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../shop/data/models/product_model.dart';
import '../../data/datasources/seller_remote_datasource.dart';
import '../controllers/seller_controller.dart';

/// Daftar listing channel (stub backend) + daftarkan produk ke channel.
class SellerChannelsPage extends StatefulWidget {
  const SellerChannelsPage({super.key});

  @override
  State<SellerChannelsPage> createState() => _SellerChannelsPageState();
}

class _SellerChannelsPageState extends State<SellerChannelsPage> {
  final _api = SellerRemoteDatasource();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  static const _channels = [
    ('tokopedia', 'Tokopedia'),
    ('shopee', 'Shopee'),
    ('other', 'Lainnya'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final c = Get.find<SellerController>();
      if (c.products.isEmpty) await c.loadProducts();
      final list = await _api.getChannelListings();
      if (mounted) setState(() => _rows = list);
    } catch (_) {
      if (mounted) setState(() => _rows = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAdd() async {
    final c = Get.find<SellerController>();
    if (c.products.isEmpty) await c.loadProducts();
    if (!mounted) return;
    if (c.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buat produk dulu di tab Produk.')),
      );
      return;
    }

    ProductModel? pick = c.products.first;
    var channel = _channels.first.$1;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.softWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 24 + MediaQuery.of(ctx).viewPadding.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setSt) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daftarkan ke channel (stub)', style: AppTextStyles.headline.copyWith(fontSize: 18)),
                  const SizedBox(height: 16),
                  Text('Produk', style: AppTextStyles.section),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ProductModel>(
                    // ignore: deprecated_member_use
                    value: pick,
                    isExpanded: true,
                    items: c.products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSt(() => pick = v),
                  ),
                  const SizedBox(height: 16),
                  Text('Channel', style: AppTextStyles.section),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: channel,
                    isExpanded: true,
                    items: _channels
                        .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                        .toList(),
                    onChanged: (v) => setSt(() => channel = v ?? channel),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: pick == null
                          ? null
                          : () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blushPink,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (ok != true || pick == null || !mounted) return;

    try {
      await _api.postChannelListing(productId: pick!.id, channel: channel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing disimpan (stub — belum sync API eksternal).')),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        title: Text('Saluran jualan', style: AppTextStyles.headline.copyWith(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: AppColors.blushPink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blushPink))
          : RefreshIndicator(
              color: AppColors.blushPink,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                children: [
                  Text(
                    'Integrasi Tokopedia/Shopee belum aktif. Baris di bawah hanya mencatat niat sync; backend mengembalikan status pending.',
                    style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  if (_rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(child: Text('Belum ada listing.', style: AppTextStyles.description)),
                    )
                  else
                    ..._rows.map((r) {
                      final ch = r['channel'] as String? ?? '';
                      final st = r['sync_status'] as String? ?? '';
                      final err = r['last_error'] as String? ?? '';
                      final pid = r['product'] as int? ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            title: Text('$ch · produk #$pid', style: AppTextStyles.type),
                            subtitle: Text(
                              '$st${err.isNotEmpty ? '\n$err' : ''}',
                              style: AppTextStyles.small,
                            ),
                            isThreeLine: err.isNotEmpty,
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
