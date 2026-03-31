import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

class WalletRemoteDatasource {
  WalletRemoteDatasource()
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
  static const String _baseUrl = 'http://127.0.0.1:8000/api/wallet';

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
    }
    return 'Gagal terhubung ke server.';
  }

  Future<Options> _authorizedOptions() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<WalletModel> getWallet() async {
    try {
      final response = await dio.get(
        '/',
        options: await _authorizedOptions(),
      );
      return WalletModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<WalletTransactionModel>> getTransactions() async {
    try {
      final response = await dio.get(
        '/transactions/',
        options: await _authorizedOptions(),
      );
      return (response.data as List)
          .map((e) => WalletTransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
