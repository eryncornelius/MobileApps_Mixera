// API models for `/api/tryon/*` (backend tryon.serializers).

import '../../../../core/network/api_base_url.dart';

String tryonResolveMediaUrl(String? pathOrUrl, {String? origin}) {
  final base = origin ?? ApiBaseUrl.origin;
  if (pathOrUrl == null || pathOrUrl.isEmpty) return '';
  if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
    return pathOrUrl;
  }
  if (pathOrUrl.startsWith('/')) return '$base$pathOrUrl';
  return '$base/$pathOrUrl';
}

enum TryOnSourceKind {
  mixResult,
  shopProduct,
}

extension TryOnSourceKindApi on TryOnSourceKind {
  String get apiValue {
    switch (this) {
      case TryOnSourceKind.mixResult:
        return 'mix_result';
      case TryOnSourceKind.shopProduct:
        return 'shop_product';
    }
  }
}

class PersonProfileImageModel {
  final int id;
  final String image;
  final String label;
  final bool isActive;
  final bool isArchived;
  final DateTime? uploadedAt;

  const PersonProfileImageModel({
    required this.id,
    required this.image,
    required this.label,
    required this.isActive,
    this.isArchived = false,
    this.uploadedAt,
  });

  factory PersonProfileImageModel.fromJson(Map<String, dynamic> json) {
    return PersonProfileImageModel(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String? ?? '',
      label: json['label'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      uploadedAt: json['uploaded_at'] != null ? DateTime.tryParse(json['uploaded_at'] as String) : null,
    );
  }
}

class TryOnResultModel {
  final int id;
  final String? resultImage;
  final String notes;
  final bool isSaved;
  final DateTime? createdAt;

  const TryOnResultModel({
    required this.id,
    this.resultImage,
    required this.notes,
    this.isSaved = false,
    this.createdAt,
  });

  factory TryOnResultModel.fromJson(Map<String, dynamic> json) {
    return TryOnResultModel(
      id: (json['id'] as num).toInt(),
      resultImage: json['result_image'] as String?,
      notes: json['notes'] as String? ?? '',
      isSaved: json['is_saved'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  TryOnResultModel copyWith({bool? isSaved}) {
    return TryOnResultModel(
      id: id,
      resultImage: resultImage,
      notes: notes,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
    );
  }
}

/// Row from GET `/tryon/results/saved/` (favourites list).
class TryOnSavedEntryModel {
  final int id;
  final int requestId;
  final String sourceType;
  final String? resultImage;
  final bool isSaved;
  final String notes;
  final DateTime? createdAt;

  const TryOnSavedEntryModel({
    required this.id,
    required this.requestId,
    required this.sourceType,
    this.resultImage,
    required this.isSaved,
    required this.notes,
    this.createdAt,
  });

  factory TryOnSavedEntryModel.fromJson(Map<String, dynamic> json) {
    return TryOnSavedEntryModel(
      id: (json['id'] as num).toInt(),
      requestId: (json['request_id'] as num).toInt(),
      sourceType: json['source_type'] as String? ?? '',
      resultImage: json['result_image'] as String?,
      isSaved: json['is_saved'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

int? _parseFk(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is Map) {
    final id = v['id'];
    if (id is num) return id.toInt();
  }
  return null;
}

class TryOnRequestDetailModel {
  final int id;
  final String status;
  final String sourceType;
  final PersonProfileImageModel personImage;
  final int? mixResultId;
  final int? shopProductId;
  final TryOnResultModel? result;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TryOnRequestDetailModel({
    required this.id,
    required this.status,
    required this.sourceType,
    required this.personImage,
    this.mixResultId,
    this.shopProductId,
    this.result,
    this.createdAt,
    this.updatedAt,
  });

  factory TryOnRequestDetailModel.fromJson(Map<String, dynamic> json) {
    TryOnResultModel? result;
    final rawResult = json['result'];
    if (rawResult is Map<String, dynamic>) {
      result = TryOnResultModel.fromJson(rawResult);
    }

    return TryOnRequestDetailModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? '',
      sourceType: json['source_type'] as String? ?? '',
      personImage: PersonProfileImageModel.fromJson(
        Map<String, dynamic>.from(json['person_image'] as Map),
      ),
      mixResultId: _parseFk(json['mix_result']),
      shopProductId: _parseFk(json['shop_product']),
      result: result,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  TryOnRequestDetailModel copyWith({TryOnResultModel? result}) {
    return TryOnRequestDetailModel(
      id: id,
      status: status,
      sourceType: sourceType,
      personImage: personImage,
      mixResultId: mixResultId,
      shopProductId: shopProductId,
      result: result ?? this.result,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
