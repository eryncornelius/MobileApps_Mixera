import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/mix_match_api_models.dart';

/// Mix generate runs OpenAI image edit; needs a long receive timeout or the client drops the connection.
class MixMatchRemoteDatasource {
  MixMatchRemoteDatasource()
      : _dio = createAuthenticatedDio(
          baseUrl: ApiBaseUrl.module('mixmatch'),
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 180),
          sendTimeout: const Duration(seconds: 60),
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

  Future<MixSessionModel> createSession() async {
    try {
      final res = await _dio.post(
        '/sessions/',
        data: const {},
      );
      return MixSessionModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<MixSessionModel> getSession(int sessionId) async {
    try {
      final res = await _dio.get('/sessions/$sessionId/');
      return MixSessionModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<MixSessionModel> selectItems(int sessionId, List<int> itemIds) async {
    try {
      final res = await _dio.post(
        '/sessions/$sessionId/select-items/',
        data: {'item_ids': itemIds},
      );
      return MixSessionModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<MixResultDetailModel> generate(int sessionId) async {
    try {
      final res = await _dio.post(
        '/sessions/$sessionId/generate/',
        data: const {},
      );
      return MixResultDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<MixResultDetailModel> getResult(int resultId) async {
    try {
      final res = await _dio.get('/results/$resultId/');
      return MixResultDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Saved / favourite mix outfits for a dedicated section.
  Future<List<MixResultDetailModel>> listSavedMixResults() async {
    try {
      final res = await _dio.get('/results/saved/');
      final list = res.data as List;
      return list
          .map((e) => MixResultDetailModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Backend toggles save; response is `{ id, is_saved }`.
  Future<bool> toggleSaveResult(int resultId) async {
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
