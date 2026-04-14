import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/models/notification_item_model.dart';

class NotificationsController extends GetxController with WidgetsBindingObserver {
  final _ds = NotificationsRemoteDatasource();

  final notifications = <NotificationItemModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    refreshUnreadCount();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshUnreadCount();
  }

  // ── Public API ───────────────────────────────────────────────────────────

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      notifications.assignAll(await _ds.getNotifications());
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      unreadCount.value = await _ds.getUnreadCount();
    } catch (_) {}
  }

  Future<void> markRead(int id) async {
    try {
      await _ds.markRead(id: id);
      final idx = notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        notifications[idx] = notifications[idx].copyWith(isRead: true);
        notifications.refresh();
      }
      if (unreadCount.value > 0) unreadCount.value--;
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _ds.markRead(all: true);
      notifications.assignAll(notifications.map((n) => n.copyWith(isRead: true)).toList());
      unreadCount.value = 0;
    } catch (_) {}
  }

  Future<void> registerFcmToken(String token) async {
    try {
      await _ds.registerFcmToken(token);
    } catch (_) {}
  }
}
