import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _c = Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    _c.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifikasi', style: AppTextStyles.headline.copyWith(fontSize: 18)),
        actions: [
          Obx(() {
            if (_c.notifications.any((n) => !n.isRead)) {
              return TextButton(
                onPressed: _c.markAllRead,
                child: Text(
                  'Tandai semua',
                  style: AppTextStyles.small.copyWith(color: AppColors.blushPink),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (_c.isLoading.value && _c.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blushPink),
          );
        }
        if (_c.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 64, color: AppColors.secondaryText.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text('Belum ada notifikasi', style: AppTextStyles.description),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _c.notifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final notif = _c.notifications[i];
            return NotificationTile(
              notif: notif,
              onTap: () => _c.markRead(notif.id),
            );
          },
        );
      }),
    );
  }
}
