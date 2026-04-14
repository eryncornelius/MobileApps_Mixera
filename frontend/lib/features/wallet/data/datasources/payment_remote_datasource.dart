import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';

class PaymentRemoteDatasource {
  PaymentRemoteDatasource()
      : dio = createAuthenticatedDio(baseUrl: ApiBaseUrl.module('payments'));

  final Dio dio;

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      if (data is Map && data.isNotEmpty) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    return 'Gagal terhubung ke server.';
  }

  /// Returns the snap_token from Midtrans.
  Future<Map<String, dynamic>> createSnapTransaction({
    required int amount,
    required String purpose,
  }) async {
    try {
      final response = await dio.post(
        '/create-snap-transaction/',
        data: {'amount': amount, 'purpose': purpose},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Polls backend for latest transaction status.
  Future<Map<String, dynamic>> getTransactionStatus(String orderId) async {
    try {
      final response = await dio.get('/status/$orderId/');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
