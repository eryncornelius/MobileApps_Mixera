// API-aligned models for `/api/wardrobe/*` (see backend wardrobe.serializers).

import '../../../../core/network/api_base_url.dart';

/// Tab order for mix-match “pick from wardrobe” (`GET /wardrobe/items/?category=`).
/// Matches backend `wardrobe.enums.ClothingCategory`.
const kWardrobePickerCategoryTabs = <(String label, String slug)>[
  ('Tops', 'top'),
  ('Bottoms', 'bottom'),
  ('Outer', 'outer'),
  ('Dress', 'dress'),
  ('Shoes', 'shoes'),
  ('Bags', 'bag'),
  ('Accessories', 'accessories'),
  ('Other', 'other'),
];

/// Stable slug order for category summary grids when merging API data.
const kWardrobeCategorySlugOrder = <String>[
  'top',
  'bottom',
  'outer',
  'dress',
  'shoes',
  'bag',
  'accessories',
  'other',
];

String resolveMediaUrl(String? pathOrUrl, {String? origin}) {
  final base = origin ?? ApiBaseUrl.origin;
  if (pathOrUrl == null || pathOrUrl.isEmpty) return '';
  if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
    return pathOrUrl;
  }
  if (pathOrUrl.startsWith('/')) return '$base$pathOrUrl';
  return '$base/$pathOrUrl';
}

class WardrobeCategorySummaryEntry {
  final String category;
  final int count;

  const WardrobeCategorySummaryEntry({required this.category, required this.count});

  factory WardrobeCategorySummaryEntry.fromJson(Map<String, dynamic> json) {
    return WardrobeCategorySummaryEntry(
      category: json['category'] as String,
      count: (json['count'] as num).toInt(),
    );
  }
}

class DetectedItemCandidateModel {
  final int id;
  final int photoId;
  final bool isSelected;
  final String category;
  final String subcategory;
  final String color;
  final List<String> styleTags;
  final double? confidence;
  final Map<String, dynamic>? boundingBox;
  final String? croppedImage;

  const DetectedItemCandidateModel({
    required this.id,
    required this.photoId,
    required this.isSelected,
    required this.category,
    required this.subcategory,
    required this.color,
    required this.styleTags,
    this.confidence,
    this.boundingBox,
    this.croppedImage,
  });

  factory DetectedItemCandidateModel.fromJson(Map<String, dynamic> json) {
    final tags = json['style_tags'];
    return DetectedItemCandidateModel(
      id: (json['id'] as num).toInt(),
      photoId: (json['photo'] as num).toInt(),
      isSelected: json['is_selected'] as bool? ?? false,
      category: json['category'] as String? ?? 'other',
      subcategory: json['subcategory'] as String? ?? '',
      color: json['color'] as String? ?? '',
      styleTags: tags is List ? tags.map((e) => e.toString()).toList() : const [],
      confidence: (json['confidence'] as num?)?.toDouble(),
      boundingBox: json['bounding_box'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['bounding_box'] as Map)
          : null,
      croppedImage: json['cropped_image'] as String?,
    );
  }

  DetectedItemCandidateModel copyWith({
    bool? isSelected,
    String? category,
    String? subcategory,
    String? color,
    List<String>? styleTags,
  }) {
    return DetectedItemCandidateModel(
      id: id,
      photoId: photoId,
      isSelected: isSelected ?? this.isSelected,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      color: color ?? this.color,
      styleTags: styleTags ?? this.styleTags,
      confidence: confidence,
      boundingBox: boundingBox,
      croppedImage: croppedImage,
    );
  }

  /// PATCH `/candidates/` — backend merges any subset of fields; selection-only is enough here.
  Map<String, dynamic> toPatchEntry() => {
        'id': id,
        'is_selected': isSelected,
      };
}

class UploadedPhotoModel {
  final int id;
  final String image;
  final DateTime? uploadedAt;
  final List<DetectedItemCandidateModel> candidates;

  const UploadedPhotoModel({
    required this.id,
    required this.image,
    this.uploadedAt,
    required this.candidates,
  });

  factory UploadedPhotoModel.fromJson(Map<String, dynamic> json) {
    final raw = json['uploaded_at'];
    return UploadedPhotoModel(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String? ?? '',
      uploadedAt: raw is String ? DateTime.tryParse(raw) : null,
      candidates: (json['candidates'] as List? ?? const [])
          .map((e) => DetectedItemCandidateModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class UploadBatchDetailModel {
  final int id;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<UploadedPhotoModel> photos;

  const UploadBatchDetailModel({
    required this.id,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.photos,
  });

  factory UploadBatchDetailModel.fromJson(Map<String, dynamic> json) {
    return UploadBatchDetailModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      photos: (json['photos'] as List? ?? const [])
          .map((e) => UploadedPhotoModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  List<DetectedItemCandidateModel> get allCandidates {
    final list = <DetectedItemCandidateModel>[];
    for (final p in photos) {
      list.addAll(p.candidates);
    }
    return list;
  }
}

class WardrobeItemApiModel {
  final int id;
  final String category;
  final String subcategory;
  final String color;
  final List<String> styleTags;
  final String image;
  final String name;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WardrobeItemApiModel({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.color,
    required this.styleTags,
    required this.image,
    required this.name,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory WardrobeItemApiModel.fromJson(Map<String, dynamic> json) {
    final tags = json['style_tags'];
    return WardrobeItemApiModel(
      id: (json['id'] as num).toInt(),
      category: json['category'] as String? ?? 'other',
      subcategory: json['subcategory'] as String? ?? '',
      color: json['color'] as String? ?? '',
      styleTags: tags is List ? tags.map((e) => e.toString()).toList() : const [],
      image: json['image'] as String? ?? '',
      name: json['name'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
}
