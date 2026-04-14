import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/datasources/seller_remote_datasource.dart';
import '../controllers/seller_controller.dart';

class SellerNotificationsPage extends StatefulWidget {
  const SellerNotificationsPage({super.key});

  @override
  State<SellerNotificationsPage> createState() => _SellerNotificationsPageState();
}

class _SellerNotificationsPageState extends State<SellerNotificationsPage> {
  final _api = SellerRemoteDatasource();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _api.getNotifications();
      if (mounted) setState(() => _items = list);
    } catch (_) {
      if (mounted) setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    await _api.markNotificationsRead(all: true);
    await Get.find<SellerController>().loadDashboard();
    await _load();
  }

  Future<void> _tapItem(int index) async {
    final n = _items[index];
    if (n['is_read'] == true) return;
    final id = n['id'];
    if (id is! int) return;
    try {
      await _api.markNotificationsRead(id: id);
      await Get.find<SellerController>().loadDashboard();
      if (mounted) {
        setState(() {
          _items[index] = {...n, 'is_read': true};
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        title: Text('Notifikasi', style: AppTextStyles.headline.copyWith(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _markAll,
            child: Text('Tandai dibaca', style: AppTextStyles.small.copyWith(color: AppColors.blushPink)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blushPink))
          : RefreshIndicator(
              color: AppColors.blushPink,
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(child: Text('Tidak ada notifikasi.', style: AppTextStyles.description)),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final n = _items[i];
                        final read = n['is_read'] as bool? ?? false;
                        return Material(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _tapItem(i),
                            child: ListTile(
                              title: Text(n['title'] as String? ?? '', style: AppTextStyles.type),
                              subtitle: Text(n['body'] as String? ?? '', style: AppTextStyles.small),
                              trailing: read
                                  ? null
                                  : const Icon(Icons.circle, size: 10, color: AppColors.blushPink),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
