import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../features/notifications/presentation/controllers/notifications_controller.dart';

/// Top-level handler — runs in an isolate when app is terminated/background.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Data is handled by the OS notification tray — nothing to do here.
}

class FcmService {
  FcmService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static const _channelId = 'mixera_notifications';
  static const _channelName = 'Mixera Notifications';

  /// Cached token so NotificationsController can register it after login.
  static String? cachedToken;

  static Future<void> init() async {
    // Background handler must be registered before anything else
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request permission (Android 13+ / iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
        enableVibration: true,
      );
      await _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Init flutter_local_notifications for foreground display
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotifTap,
    );

    // Foreground message → show local notification
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // App opened from notification tap (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // App launched from terminated state via notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleTap(initial);

    // Register token to backend
    await _registerToken();
    _messaging.onTokenRefresh.listen((_) => _registerToken());
  }

  // ── Handlers ────────────────────────────────────────────────────────────

  static void _handleForeground(RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return;

    _localNotif.show(
      msg.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: msg.data['order_id']?.toString(),
    );

    // Refresh badge count
    _refreshCount();
  }

  static void _handleTap(RemoteMessage msg) {
    _refreshCount();
    // TODO: deep-link based on msg.data['order_id'] if needed
  }

  static void _onNotifTap(NotificationResponse response) {
    _refreshCount();
  }

  static void _refreshCount() {
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().refreshUnreadCount();
    }
  }

  // ── Token registration ───────────────────────────────────────────────────

  static Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      cachedToken = token;
      // Will be sent to backend after login via registerAfterLogin()
    } catch (_) {
      // Non-fatal
    }
  }

  /// Call this right after a successful login so the token is sent
  /// while the user is authenticated.
  static Future<void> registerAfterLogin() async {
    try {
      final token = cachedToken ?? await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      cachedToken = token;
      if (Get.isRegistered<NotificationsController>()) {
        await Get.find<NotificationsController>().registerFcmToken(token);
      }
    } catch (_) {}
  }
}
