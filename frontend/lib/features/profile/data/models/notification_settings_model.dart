class NotificationSettingsModel {
  final bool orderUpdates;
  final bool promotions;
  final bool securityAlerts;
  final bool dailyReminders;

  const NotificationSettingsModel({
    required this.orderUpdates,
    required this.promotions,
    required this.securityAlerts,
    required this.dailyReminders,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      orderUpdates: json['order_updates'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? true,
      securityAlerts: json['security_alerts'] as bool? ?? false,
      dailyReminders: json['daily_reminders'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_updates': orderUpdates,
      'promotions': promotions,
      'security_alerts': securityAlerts,
      'daily_reminders': dailyReminders,
    };
  }

  NotificationSettingsModel copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? securityAlerts,
    bool? dailyReminders,
  }) {
    return NotificationSettingsModel(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      securityAlerts: securityAlerts ?? this.securityAlerts,
      dailyReminders: dailyReminders ?? this.dailyReminders,
    );
  }
}
