import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/datasources/seller_remote_datasource.dart';
import '../controllers/seller_controller.dart';

class SellerOrderDetailPage extends StatefulWidget {
  final int orderId;
  const SellerOrderDetailPage({super.key, required this.orderId});

  @override
  State<SellerOrderDetailPage> createState() => _SellerOrderDetailPageState();
}

class _SellerOrderDetailPageState extends State<SellerOrderDetailPage> {
  final _api = SellerRemoteDatasource();
  final _tracking = TextEditingController();
  final _courier = TextEditingController();
  Map<String, dynamic>? _order;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tracking.dispose();
    _courier.dispose();
    super.dispose();
  }

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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final o = await _api.getOrder(widget.orderId);
      _tracking.text = o['tracking_number'] as String? ?? '';
      _courier.text = o['shipping_courier'] as String? ?? '';
      _order = o;
    } catch (_) {
      _order = null;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ship() async {
    final t = _tracking.text.trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nomor resi.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await Get.find<SellerController>().shipOrder(
        widget.orderId,
        tracking: t,
        courier: _courier.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status diperbarui.')),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    try {
      await Get.find<SellerController>().completeOrder(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan ditandai selesai.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = _order?['status'] as String? ?? '';
    final paid = (_order?['payment_status'] as String? ?? '') == 'paid';
    final canShip = paid && st == 'processing';
    final canComplete = paid && st == 'shipped';

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        title: Text('Order #${widget.orderId}', style: AppTextStyles.headline.copyWith(fontSize: 18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blushPink))
          : _order == null
              ? Center(child: Text('Tidak ditemukan.', style: AppTextStyles.description))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.softWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Informasi Status', style: AppTextStyles.section),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Status Pesanan', style: AppTextStyles.small),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.roseMist,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(st.toUpperCase(), style: AppTextStyles.small.copyWith(color: AppColors.blushPink, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Status Pembayaran', style: AppTextStyles.small),
                                    Text('${_order!['payment_status']}'.toUpperCase(), style: AppTextStyles.type),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Buyer address
                          if (_order!['address_snapshot'] != null) ...[
                            const SizedBox(height: 24),
                            Builder(builder: (_) {
                              final addr = Map<String, dynamic>.from(
                                  _order!['address_snapshot'] as Map);
                              final recipient = addr['recipient_name']?.toString() ?? '';
                              final phone = addr['phone_number']?.toString() ?? '';
                              final street = addr['street_address']?.toString() ?? '';
                              final city = addr['city']?.toString() ?? '';
                              final state = addr['state']?.toString() ?? '';
                              final postal = addr['postal_code']?.toString() ?? '';
                              final addressLine = [street, city, state, postal]
                                  .where((v) => v.isNotEmpty)
                                  .join(', ');
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.softWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined,
                                            size: 18, color: AppColors.blushPink),
                                        const SizedBox(width: 6),
                                        Text('Alamat Penerima', style: AppTextStyles.section),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (recipient.isNotEmpty) ...[
                                      Text(recipient, style: AppTextStyles.productName),
                                      const SizedBox(height: 4),
                                    ],
                                    if (phone.isNotEmpty) ...[
                                      Text(phone, style: AppTextStyles.small),
                                      const SizedBox(height: 4),
                                    ],
                                    if (addressLine.isNotEmpty)
                                      Text(addressLine, style: AppTextStyles.small),
                                  ],
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 24),
                          if ((_order!['items'] as List?)?.isNotEmpty == true) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.softWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Daftar Produk', style: AppTextStyles.section),
                                  const SizedBox(height: 16),
                                  ...((_order!['items'] as List).map((raw) {
                                    final it = Map<String, dynamic>.from(raw as Map);
                                    final name = it['product_name'] as String? ?? '';
                                    final size = it['variant_size'] as String? ?? '';
                                    final qty = it['quantity'] as int? ?? 0;
                                    final unitPrice = it['unit_price'] as int? ?? 0;
                                    final lineTotal = it['line_total'] as int? ?? 0;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: AppColors.warmCream,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.inventory_2_outlined, color: AppColors.secondaryText, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(name, style: AppTextStyles.productName.copyWith(fontSize: 14)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  [
                                                    if (size.isNotEmpty) 'Size: $size',
                                                    'Qty: $qty',
                                                    '@ ${_fmt(unitPrice)}',
                                                  ].join(' · '),
                                                  style: AppTextStyles.small,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _fmt(lineTotal),
                                            style: AppTextStyles.small.copyWith(
                                              color: AppColors.blushPink,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.softWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Informasi Pengiriman', style: AppTextStyles.section),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _tracking,
                                  decoration: const InputDecoration(labelText: 'Nomor resi'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _courier,
                                  decoration: const InputDecoration(labelText: 'Kurir (opsional)'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canShip || canComplete || !paid || (paid && !canShip && !canComplete))
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          border: const Border(top: BorderSide(color: AppColors.border)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (canShip)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _ship,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blushPink,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Tandai Dikirim', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            if (canComplete)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _complete,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blushPink,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Tandai Selesai', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            if (!canShip && !canComplete && paid)
                              Text(
                                (st == 'delivered' || st == 'completed')
                                    ? 'Pesanan telah selesai.'
                                    : 'Menunggu status yang dapat diperbarui...',
                                style: AppTextStyles.small,
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
