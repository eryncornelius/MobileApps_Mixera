class QuickActionModel {
  final String id;
  final String label;
  final String iconName;
  final String? route;

  const QuickActionModel({
    required this.id,
    required this.label,
    required this.iconName,
    this.route,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id'] as String,
      label: json['label'] as String,
      iconName: json['icon_name'] as String,
      route: json['route'] as String?,
    );
  }
}
