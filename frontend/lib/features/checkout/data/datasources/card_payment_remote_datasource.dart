import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../models/card_charge_result_model.dart';
import '../models/saved_card_model.dart';

class CardPaymentRemoteDatasource {
  CardPaymentRemoteDatasource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _base,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;
  static const String _base = 'http://127.0.0.1:8000/api/payments';

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Payment request failed. Please try again.';
  }

  Future<Options> _auth() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<CardChargeResultModel> chargeCard({
    required int orderId,
    String cardToken = '',
    int? savedCardId,
    bool saveCard = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'django_order_id': orderId,
        'save_card': saveCard,
      };
      if (cardToken.isNotEmpty) data['card_token'] = cardToken;
      if (savedCardId != null) data['saved_card_id'] = savedCardId;

      final res = await _dio.post(
        '/card/charge/',
        data: data,
        options: await _auth(),
      );
      return CardChargeResultModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<SavedCardModel>> getSavedCards() async {
    try {
      final res = await _dio.get('/cards/', options: await _auth());
      return (res.data as List)
          .map((e) => SavedCardModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> setDefaultCard(int id) async {
    try {
      await _dio.patch('/cards/$id/default/', options: await _auth());
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteCard(int id) async {
    try {
      await _dio.delete('/cards/$id/', options: await _auth());
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> getTransactionStatus(String midtransOrderId) async {
    try {
      final res = await _dio.get(
        '/status/$midtransOrderId/',
        options: await _auth(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
