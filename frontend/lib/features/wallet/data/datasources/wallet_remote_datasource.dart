import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

class WalletRemoteDatasource {
  WalletRemoteDatasource()
      : dio = createAuthenticatedDio(baseUrl: ApiBaseUrl.module('wallet'));

  final Dio dio;

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
    }
    return 'Gagal terhubung ke server.';
  }

  Future<WalletModel> getWallet() async {
    try {
      final response = await dio.get('/');
      return WalletModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<WalletTransactionModel>> getTransactions() async {
    try {
      final response = await dio.get('/transactions/');
      return (response.data as List)
          .map((e) => WalletTransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
