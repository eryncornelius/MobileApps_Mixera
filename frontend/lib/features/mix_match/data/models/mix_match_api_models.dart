import '../../../wardrobe/data/models/wardrobe_api_models.dart';

/// MixResult from generate / GET `/results/{id}/` (detail includes `selected_items`).
class MixResultDetailModel {
  final int id;
  final String styleLabel;
  final String explanation;
  final String tips;
  final int score;
  final bool isSaved;
  /// Backend-composed outfit preview (single image), if generation succeeded.
  final String? previewImage;
  final DateTime? createdAt;
  /// Single winning outfit (best candidate from the pool).
  final List<WardrobeItemApiModel> selectedItems;
  /// Full wardrobe picks before narrowing (optional; same as session `selected_items`).
  final List<WardrobeItemApiModel> allSelectedItems;

  const MixResultDetailModel({
    required this.id,
    required this.styleLabel,
    required this.explanation,
    required this.tips,
    required this.score,
    required this.isSaved,
    this.previewImage,
    this.createdAt,
    this.selectedItems = const [],
    this.allSelectedItems = const [],
  });

  factory MixResultDetailModel.fromJson(Map<String, dynamic> json) {
    List<WardrobeItemApiModel> parseItems(String key) {
      final raw = json[key] as List?;
      if (raw == null) return const [];
      return raw
          .map((e) => WardrobeItemApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return MixResultDetailModel(
      id: (json['id'] as num).toInt(),
      styleLabel: json['style_label'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      tips: json['tips'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      isSaved: json['is_saved'] as bool? ?? false,
      previewImage: json['preview_image'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      selectedItems: parseItems('selected_items'),
      allSelectedItems: parseItems('all_selected_items'),
    );
  }

  MixResultDetailModel copyWith({bool? isSaved, String? previewImage}) {
    return MixResultDetailModel(
      id: id,
      styleLabel: styleLabel,
      explanation: explanation,
      tips: tips,
      score: score,
      isSaved: isSaved ?? this.isSaved,
      previewImage: previewImage ?? this.previewImage,
      createdAt: createdAt,
      selectedItems: selectedItems,
      allSelectedItems: allSelectedItems,
    );
  }
}

/// Nested `result` on session (no `selected_items`).
class MixResultSummaryModel {
  final int id;
  final String styleLabel;
  final String explanation;
  final String tips;
  final int score;
  final bool isSaved;
  final String? previewImage;
  final DateTime? createdAt;

  const MixResultSummaryModel({
    required this.id,
    required this.styleLabel,
    required this.explanation,
    required this.tips,
    required this.score,
    required this.isSaved,
    this.previewImage,
    this.createdAt,
  });

  factory MixResultSummaryModel.fromJson(Map<String, dynamic> json) {
    return MixResultSummaryModel(
      id: (json['id'] as num).toInt(),
      styleLabel: json['style_label'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      tips: json['tips'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      isSaved: json['is_saved'] as bool? ?? false,
      previewImage: json['preview_image'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

class MixSessionModel {
  final int id;
  final String status;
  final List<WardrobeItemApiModel> selectedItems;
  final MixResultSummaryModel? result;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MixSessionModel({
    required this.id,
    required this.status,
    required this.selectedItems,
    this.result,
    this.createdAt,
    this.updatedAt,
  });

  factory MixSessionModel.fromJson(Map<String, dynamic> json) {
    final items = (json['selected_items'] as List? ?? const [])
        .map((e) => WardrobeItemApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    MixResultSummaryModel? res;
    final raw = json['result'];
    if (raw is Map<String, dynamic>) {
      res = MixResultSummaryModel.fromJson(raw);
    }
    return MixSessionModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? '',
      selectedItems: items,
      result: res,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
}
