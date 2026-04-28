import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/wardrobe_api_models.dart';

class WardrobeRemoteDatasource {
  WardrobeRemoteDatasource()
      : _dio = createAuthenticatedDio(
          baseUrl: ApiBaseUrl.module('wardrobe'),
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        );

  final Dio _dio;

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.isNotEmpty) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    return 'Gagal terhubung ke server. Periksa koneksi Anda.';
  }

  /// POST multipart: field name `images` (1–3 files).
  Future<UploadBatchDetailModel> createUploadBatch(List<String> imagePaths) async {
    if (imagePaths.isEmpty) {
      throw Exception('Pilih minimal satu foto.');
    }
    final form = FormData();
    for (final path in imagePaths) {
      form.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(path, filename: path.split(RegExp(r'[/\\]')).last),
        ),
      );
    }
    try {
      final res = await _dio.post(
        '/upload-batches/',
        data: form,
      );
      return UploadBatchDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<UploadBatchDetailModel> getUploadBatchDetail(int batchId) async {
    try {
      final res = await _dio.get('/upload-batches/$batchId/');
      return UploadBatchDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<DetectedItemCandidateModel>> patchCandidates(
    int batchId,
    List<Map<String, dynamic>> candidates,
  ) async {
    try {
      final res = await _dio.patch(
        '/upload-batches/$batchId/candidates/',
        data: {'candidates': candidates},
      );
      final list = res.data as List;
      return list
          .map((e) => DetectedItemCandidateModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<WardrobeItemApiModel>> confirmBatch(int batchId) async {
    try {
      final res = await _dio.post(
        '/upload-batches/$batchId/confirm/',
      );
      final list = res.data as List;
      return list
          .map((e) => WardrobeItemApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<WardrobeItemApiModel>> getWardrobeItems({String? category}) async {
    try {
      final res = await _dio.get(
        '/items/',
        queryParameters: category != null && category.isNotEmpty ? {'category': category} : null,
      );
      final list = res.data as List;
      return list
          .map((e) => WardrobeItemApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<WardrobeItemApiModel> patchItem(
    int id, {
    String? name,
    bool? isFavourite,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (isFavourite != null) body['is_favourite'] = isFavourite;
    try {
      final res = await _dio.patch('/items/$id/', data: body);
      return WardrobeItemApiModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _dio.delete('/items/$id/');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<WardrobeCategorySummaryEntry>> getCategorySummary() async {
    try {
      final res = await _dio.get('/categories/summary/');
      final list = res.data as List;
      return list
          .map((e) => WardrobeCategorySummaryEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
