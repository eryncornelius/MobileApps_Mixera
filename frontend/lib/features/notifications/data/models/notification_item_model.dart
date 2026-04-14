class NotificationItemModel {
  final int id;
  final String notifType;
  final String title;
  final String body;
  final bool isRead;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const NotificationItemModel({
    required this.id,
    required this.notifType,
    required this.title,
    required this.body,
    required this.isRead,
    required this.payload,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as int,
      notifType: json['notif_type'] as String? ?? 'system',
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  NotificationItemModel copyWith({bool? isRead}) => NotificationItemModel(
        id: id,
        notifType: notifType,
        title: title,
        body: body,
        isRead: isRead ?? this.isRead,
        payload: payload,
        createdAt: createdAt,
      );
}
