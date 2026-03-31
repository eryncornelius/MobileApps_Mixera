import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';

class PaymentRemoteDatasource {
  PaymentRemoteDatasource()
      : dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  final Dio dio;
  static const String _baseUrl = 'http://127.0.0.1:8000/api/payments';

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

  Future<Options> _authorizedOptions() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
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
        options: await _authorizedOptions(),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Polls backend for latest transaction status.
  Future<Map<String, dynamic>> getTransactionStatus(String orderId) async {
    try {
      final response = await dio.get(
        '/status/$orderId/',
        options: await _authorizedOptions(),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
