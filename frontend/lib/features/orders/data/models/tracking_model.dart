class TrackingHistoryItem {
  final String status;
  final String note;
  final String updatedTime;

  const TrackingHistoryItem({
    required this.status,
    required this.note,
    required this.updatedTime,
  });

  factory TrackingHistoryItem.fromJson(Map<String, dynamic> json) {
    return TrackingHistoryItem(
      status: json['status'] as String? ?? '',
      note: json['note'] as String? ?? '',
      updatedTime: json['updated_time'] as String? ?? '',
    );
  }
}

class TrackingModel {
  final String waybill;
  final String courier;
  final String status;
  final List<TrackingHistoryItem> history;

  const TrackingModel({
    required this.waybill,
    required this.courier,
    required this.status,
    required this.history,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      waybill: json['waybill'] as String? ?? '',
      courier: json['courier'] as String? ?? '',
      status: json['status'] as String? ?? '',
      history: (json['history'] as List? ?? [])
          .map((e) => TrackingHistoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
