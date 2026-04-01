import 'package:flutter/material.dart';
class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFF0A0B0), size: 20),
          onPressed: () {},
        ),
        title: const Text(
          'MIXÉRA',
          style: TextStyle(
            color: Color(0xFFF0A0B0),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF4A4A5F)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay Updated with your latest activity',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const Text('Today', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildNotificationCard(
                    icon: Icons.payments_outlined,
                    title: 'Payment Successful',
                    subtitle: 'Your payment of Rp 179.000 was successful',
                    time: '2m ago',
                    isUnread: true,
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationCard(
                    icon: Icons.card_giftcard,
                    title: 'Order Shipped',
                    subtitle: 'Your order is on the way!',
                    time: '1h ago',
                    isUnread: true,
                  ),
                  const SizedBox(height: 20),
                  const Text('Yesterday', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildNotificationCard(
                    icon: Icons.security,
                    title: 'Security Alert',
                    subtitle: 'New login detected from Jakarta Selatan, Indonesia',
                    time: 'Yesterday',
                    isUnread: true,
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationCard(
                    icon: Icons.auto_awesome,
                    title: 'Promo Alert',
                    subtitle: 'Enjoy 20% off on your next purchase! Use code: Mix20',
                    time: 'Yesterday',
                    isUnread: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDFE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFF0A0B0), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A5F), fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  if (isUnread) ...[
                    const SizedBox(width: 4),
                    const CircleAvatar(radius: 3, backgroundColor: Color(0xFFF0A0B0)),
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool orderUpdates = false;
  bool promotions = false;
  bool securityAlerts = false;
  bool dailyReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFF0A0B0), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MIXÉRA',
          style: TextStyle(
            color: Color(0xFFF0A0B0),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF4A4A5F)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose which notification you\'d like to receive',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.card_giftcard,
                  title: 'Order Updates',
                  subtitle: 'Keep track of your order status and delivery updates',
                  value: orderUpdates,
                  onChanged: (val) => setState(() => orderUpdates = val),
                ),
                _divider(),
                _buildSettingItem(
                  icon: Icons.percent,
                  title: 'Promotions',
                  subtitle: 'Receive exclusive offers, discounts, and special deals',
                  value: promotions,
                  onChanged: (val) => setState(() => promotions = val),
                ),
                _divider(),
                _buildSettingItem(
                  icon: Icons.security,
                  title: 'Security Alerts',
                  subtitle: 'Receive alerts when there is a security alert',
                  value: securityAlerts,
                  onChanged: (val) => setState(() => securityAlerts = val),
                ),
                _divider(),
                _buildSettingItem(
                  icon: Icons.auto_awesome,
                  title: 'Daily Reminders',
                  subtitle: 'Get daily reminders to style or for outfit recommendations',
                  value: dailyReminders,
                  onChanged: (val) => setState(() => dailyReminders = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDFE5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFF0A0B0), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A5F), fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFF0A0B0), 
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 70, 
      endIndent: 20,
    );
  }
}