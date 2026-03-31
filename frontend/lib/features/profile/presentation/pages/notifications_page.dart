import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';
import '../widgets/notification_toggle_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late bool _orderUpdates;
  late bool _promotions;
  late bool _securityAlerts;
  late bool _dailyReminders;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final profileC = Get.find<ProfileController>();
    await profileC.fetchNotificationSettings();
    final s = profileC.notificationSettings.value;
    if (s != null && mounted) {
      setState(() {
        _orderUpdates = s.orderUpdates;
        _promotions = s.promotions;
        _securityAlerts = s.securityAlerts;
        _dailyReminders = s.dailyReminders;
        _initialized = true;
      });
    } else if (mounted) {
      setState(() {
        _orderUpdates = true;
        _promotions = true;
        _securityAlerts = false;
        _dailyReminders = false;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileC = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              _buildHeader(context),
              const SizedBox(height: 24),
              Obx(() {
                if (profileC.isLoadingNotificationSettings.value ||
                    !_initialized) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.blushPink),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      NotificationToggleTile(
                        icon: Icons.card_giftcard_rounded,
                        iconBgColor: AppColors.roseMist,
                        iconColor: AppColors.blushPink,
                        title: 'Order Updates',
                        description: 'Keep track of your order status and delivery updates',
                        value: _orderUpdates,
                        onChanged: (val) => setState(() => _orderUpdates = val),
                      ),
                      Divider(height: 1, color: AppColors.border),
                      NotificationToggleTile(
                        icon: Icons.local_offer_rounded,
                        iconBgColor: AppColors.roseMist,
                        iconColor: AppColors.blushPink,
                        title: 'Promotions',
                        description: 'Receive exclusive offers, discounts, and special deals',
                        value: _promotions,
                        onChanged: (val) => setState(() => _promotions = val),
                      ),
                      Divider(height: 1, color: AppColors.border),
                      NotificationToggleTile(
                        icon: Icons.shield_rounded,
                        iconBgColor: AppColors.roseMist,
                        iconColor: AppColors.blushPink,
                        title: 'Security Alerts',
                        description: 'Receive alerts when there is a security alert',
                        value: _securityAlerts,
                        onChanged: (val) => setState(() => _securityAlerts = val),
                      ),
                      Divider(height: 1, color: AppColors.border),
                      NotificationToggleTile(
                        icon: Icons.auto_awesome_rounded,
                        iconBgColor: AppColors.roseMist,
                        iconColor: AppColors.blushPink,
                        title: 'Daily Reminders',
                        description: 'Get daily reminders to style or for outfit recommendations',
                        value: _dailyReminders,
                        onChanged: (val) => setState(() => _dailyReminders = val),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 28),
              Obx(() => ElevatedButton(
                    onPressed: profileC.isSavingNotificationSettings.value
                        ? null
                        : () async {
                            await profileC.saveNotificationSettings(
                              orderUpdates: _orderUpdates,
                              promotions: _promotions,
                              securityAlerts: _securityAlerts,
                              dailyReminders: _dailyReminders,
                            );
                          },
                    child: profileC.isSavingNotificationSettings.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Save Preferences'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left_rounded,
                  size: 28, color: AppColors.primaryText),
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
            const SizedBox(width: 28),
          ],
        ),
        const SizedBox(height: 20),
        Text('Notifications', style: AppTextStyles.headline),
        const SizedBox(height: 6),
        Text(
          "Choose which notification you'd like to receive",
          style: AppTextStyles.description,
        ),
      ],
    );
  }
}
