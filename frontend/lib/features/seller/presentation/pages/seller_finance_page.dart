import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/datasources/seller_remote_datasource.dart';
import '../controllers/seller_controller.dart';

/// Ringkasan mutasi, payout, stub ongkir, export CSV pendapatan.
class SellerFinancePage extends StatefulWidget {
  const SellerFinancePage({super.key});

  @override
  State<SellerFinancePage> createState() => _SellerFinancePageState();
}

class _SellerFinancePageState extends State<SellerFinancePage> {
  final _payoutAmount = TextEditingController();
  final _weight = TextEditingController(text: '500');
  final _city = TextEditingController();
  final _postal = TextEditingController();
  bool _loadingEarnings = false;
  bool _loadingPayouts = false;
  bool _exportingCsv = false;
  List<Map<String, dynamic>> _earnings = [];
  List<Map<String, dynamic>> _payouts = [];
  String? _shippingNote;

  @override
  void dispose() {
    _payoutAmount.dispose();
    _weight.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _reloadLists();
  }

  Future<void> _reloadLists() async {
    final api = SellerRemoteDatasource();
    setState(() {
      _loadingEarnings = true;
      _loadingPayouts = true;
    });
    try {
      final e = await api.getFinanceEarnings();
      if (mounted) setState(() => _earnings = e);
    } catch (_) {
      if (mounted) setState(() => _earnings = []);
    } finally {
      if (mounted) setState(() => _loadingEarnings = false);
    }
    try {
      final p = await api.getFinancePayouts();
      if (mounted) setState(() => _payouts = p);
    } catch (_) {
      if (mounted) setState(() => _payouts = []);
    } finally {
      if (mounted) setState(() => _loadingPayouts = false);
    }
  }

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

  Future<void> _requestPayout() async {
    final raw = _payoutAmount.text.trim().replaceAll(RegExp(r'\D'), '');
    final amt = int.tryParse(raw);
    if (amt == null || amt < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak valid.')),
      );
      return;
    }
    try {
      await Get.find<SellerController>().requestPayout(amt);
      _payoutAmount.clear();
      await _reloadLists();
      await Get.find<SellerController>().loadDashboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan pencairan dikirim (pending admin).')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  /// Unduh CSV dari API, simpan ke file temp, buka share sheet (Drive, Files, email, dll.).
  Future<void> _exportEarningsCsv() async {
    if (_exportingCsv) return;
    setState(() => _exportingCsv = true);
    try {
      final csv = await SellerRemoteDatasource().downloadEarningsCsv();
      final stamp = DateTime.now().toUtc().toIso8601String().split('.').first.replaceAll(':', '');
      final fileName = 'mixera_pendapatan_$stamp.csv';
      final file = File('${Directory.systemTemp.path}/$fileName');
      await file.writeAsString(csv, flush: true);
      if (!mounted) return;
      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'text/csv',
            name: fileName,
          ),
        ],
        subject: 'Export pendapatan MIXÉRA',
        text: 'Data pendapatan penjual (maks. 2000 baris terbaru).',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingCsv = false);
    }
  }

  Future<void> _stubQuote() async {
    final w = int.tryParse(_weight.text.trim()) ?? 500;
    try {
      final res = await SellerRemoteDatasource().postShippingQuote(
        weightGrams: w,
        destinationCity: _city.text.trim(),
        destinationPostalCode: _postal.text.trim(),
      );
      final note = res['note'] as String? ?? '';
      final quotes = (res['quotes'] as List?) ?? [];
      if (!mounted) return;
      setState(() => _shippingNote = note);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Estimasi ongkir', style: AppTextStyles.type),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(note, style: AppTextStyles.small),
                const SizedBox(height: 12),
                ...quotes.map((q) {
                  final m = Map<String, dynamic>.from(q as Map);
                  final dur = m['duration'];
                  final durStr = dur is String ? dur : (dur?.toString() ?? '');
                  final eta = m['eta_days'];
                  final etaStr = durStr.isNotEmpty ? ' · $durStr' : ' · ~$eta hari';
                  final prov = m['provider'] ?? 'stub';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${m['courier']} ${m['service']} — ${_fmtRp((m['price'] as num?)?.toInt() ?? 0)}$etaStr ($prov)',
                      style: AppTextStyles.description,
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
        ),
      );
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
    final c = Get.find<SellerController>();
    return Obx(() {
      final d = c.dashboard.value;
      final bal = (d?['available_balance'] as num?)?.toInt() ?? 0;
      return RefreshIndicator(
        color: AppColors.blushPink,
        onRefresh: () async {
          await c.loadDashboard();
          await _reloadLists();
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blushPink, AppColors.roseMist],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.blushPink.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text('Saldo Tersedia', style: AppTextStyles.section.copyWith(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_fmtRp(bal), style: AppTextStyles.headline.copyWith(color: Colors.white, fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    'Estimasi saldo, diproses admin secara berkala.',
                    style: AppTextStyles.small.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  Text('Tarik Saldo', style: AppTextStyles.section),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _payoutAmount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal Pencairan (Rp)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _requestPayout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blushPink,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ajukan Pencairan', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _exportingCsv ? null : _exportEarningsCsv,
                      child: _exportingCsv
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.blushPink,
                              ),
                            )
                          : Text(
                              'Export CSV pendapatan',
                              style: AppTextStyles.small.copyWith(color: AppColors.primaryText),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  Text('Cek Ongkir', style: AppTextStyles.section),
                  const SizedBox(height: 8),
                  Text(
                    'Isi form untuk mengecek tarif via eksternal API.',
                    style: AppTextStyles.small.copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weight,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Berat (gram)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kode Pos Tujuan',
                      hintText: 'mis. 40181',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _city,
                    decoration: const InputDecoration(
                      labelText: 'Kota / Alamat (opsional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _stubQuote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roseMist,
                        foregroundColor: AppColors.blushPink,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Hitung Ongkir', style: AppTextStyles.small.copyWith(color: AppColors.blushPink, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (_shippingNote != null) ...[
                    const SizedBox(height: 12),
                    Text(_shippingNote!, style: AppTextStyles.small),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Penarikan Payout', style: AppTextStyles.section),
            const SizedBox(height: 12),
            if (_loadingPayouts)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.blushPink)))
            else if (_payouts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Belum ada pengajuan pencairan.', style: AppTextStyles.description),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: _payouts.map((p) {
                    final st = p['status'] as String? ?? '';
                    final amt = (p['amount'] as num?)?.toInt() ?? 0;
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warmCream,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.outbound, color: AppColors.secondaryText, size: 20),
                        ),
                        title: Text(st.toUpperCase(), style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600)),
                        trailing: Text(_fmtRp(amt), style: AppTextStyles.type),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),
            Text('Riwayat Pendapatan', style: AppTextStyles.section),
            const SizedBox(height: 12),
            if (_loadingEarnings)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.blushPink)))
            else if (_earnings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Belum ada riwayat pendapatan.', style: AppTextStyles.description),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: _earnings.take(20).map((e) {
                    final net = (e['net_to_seller'] as num?)?.toInt() ?? 0;
                    final oid = e['order'] as int? ?? 0;
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warmCream,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_card, color: AppColors.success, size: 20),
                        ),
                        title: Text('Order #$oid', style: AppTextStyles.small),
                        trailing: Text('+ ${_fmtRp(net)}', style: AppTextStyles.type.copyWith(color: AppColors.success)),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      );
    });
  }
}
