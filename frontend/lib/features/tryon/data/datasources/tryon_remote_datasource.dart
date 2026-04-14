import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/tryon_api_models.dart';

/// OpenAI try-on can run well over 60s; short timeouts cause client disconnect → server "Broken pipe".
class TryOnRemoteDatasource {
  TryOnRemoteDatasource()
      : _dio = createAuthenticatedDio(
          baseUrl: ApiBaseUrl.module('tryon'),
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 180),
          sendTimeout: const Duration(seconds: 120),
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

  Future<List<PersonProfileImageModel>> listPersonImages() async {
    try {
      final res = await _dio.get('/person-images/');
      final list = res.data as List;
      return list
          .map((e) => PersonProfileImageModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<PersonProfileImageModel> uploadPersonImage(
    String filePath, {
    String label = '',
    bool setActive = false,
  }) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split(RegExp(r'[/\\]')).last,
      ),
      'label': label,
      'set_active': setActive ? 'true' : 'false',
    });
    try {
      final res = await _dio.post(
        '/person-images/',
        data: form,
      );
      return PersonProfileImageModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<PersonProfileImageModel> activatePersonImage(int imageId) async {
    try {
      final res = await _dio.patch(
        '/person-images/$imageId/activate/',
      );
      return PersonProfileImageModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Backend soft-archives (hides from list; keeps row for try-on history / PROTECT FK).
  Future<void> archivePersonImage(int imageId) async {
    try {
      await _dio.delete('/person-images/$imageId/');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<TryOnRequestDetailModel> createTryOnRequest({
    required int personImageId,
    required TryOnSourceKind sourceType,
    int? mixResultId,
    int? shopProductId,
  }) async {
    final body = <String, dynamic>{
      'person_image_id': personImageId,
      'source_type': sourceType.apiValue,
    };
    if (sourceType == TryOnSourceKind.mixResult) {
      body['mix_result_id'] = mixResultId;
    } else {
      body['shop_product_id'] = shopProductId;
    }

    try {
      final res = await _dio.post(
        '/requests/',
        data: body,
      );
      return TryOnRequestDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<TryOnRequestDetailModel> getTryOnRequest(int requestId) async {
    try {
      final res = await _dio.get('/requests/$requestId/');
      return TryOnRequestDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Favourited try-on results for home / saved section.
  Future<List<TryOnSavedEntryModel>> listSavedTryOnResults() async {
    try {
      final res = await _dio.get('/results/saved/');
      final list = res.data as List;
      return list
          .map((e) => TryOnSavedEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Returns new `is_saved` value.
  Future<bool> toggleTryOnSave(int resultId) async {
    try {
      final res = await _dio.post(
        '/results/$resultId/save/',
        data: const {},
      );
      final map = Map<String, dynamic>.from(res.data as Map);
      return map['is_saved'] as bool? ?? false;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
