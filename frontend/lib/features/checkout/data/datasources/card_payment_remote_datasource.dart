import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/card_charge_result_model.dart';
import '../models/saved_card_model.dart';

class CardChargeApiException implements Exception {
  final String message;
  final String? code;
  final String? action;

  const CardChargeApiException({
    required this.message,
    this.code,
    this.action,
  });

  bool get shouldUseNewCard =>
      code == 'saved_card_token_invalid' || action == 'use_new_card';

  @override
  String toString() => message;
}

class CardPaymentRemoteDatasource {
  CardPaymentRemoteDatasource()
      : _dio = createAuthenticatedDio(
          baseUrl: ApiBaseUrl.module('payments'),
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        );

  final Dio _dio;

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Payment request failed. Please try again.';
  }

  CardChargeApiException _parseChargeError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return CardChargeApiException(
        message: map['detail']?.toString() ?? 'Payment request failed. Please try again.',
        code: map['code']?.toString(),
        action: map['action']?.toString(),
      );
    }
    return CardChargeApiException(message: _handleError(e));
  }

  Future<CardChargeResultModel> chargeCard({
    required int orderId,
    String cardToken = '',
    int? savedCardId,
    bool saveCard = false,
    bool retryThreeDs = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'django_order_id': orderId,
        'save_card': saveCard,
        if (retryThreeDs) 'retry_three_ds': true,
      };
      if (cardToken.isNotEmpty) data['card_token'] = cardToken;
      if (savedCardId != null) data['saved_card_id'] = savedCardId;

      final res = await _dio.post(
        '/card/charge/',
        data: data,
      );
      return CardChargeResultModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw _parseChargeError(e);
    }
  }

  /// Top-up saldo wallet via Core API (kartu baru atau [savedCardId]).
  Future<CardChargeResultModel> chargeWalletTopUp({
    required int amount,
    String cardToken = '',
    int? savedCardId,
    bool saveCard = false,
    bool retryThreeDs = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'charge_purpose': 'wallet_topup',
        'amount': amount,
        'save_card': saveCard,
        if (retryThreeDs) 'retry_three_ds': true,
      };
      if (cardToken.isNotEmpty) data['card_token'] = cardToken;
      if (savedCardId != null) data['saved_card_id'] = savedCardId;

      final res = await _dio.post(
        '/card/charge/',
        data: data,
      );
      return CardChargeResultModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw _parseChargeError(e);
    }
  }

  Future<List<SavedCardModel>> getSavedCards() async {
    try {
      final res = await _dio.get('/cards/');
      return (res.data as List)
          .map((e) => SavedCardModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> setDefaultCard(int id) async {
    try {
      await _dio.patch('/cards/$id/default/');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteCard(int id) async {
    try {
      await _dio.delete('/cards/$id/');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> getTransactionStatus(String midtransOrderId) async {
    try {
      final res = await _dio.get('/status/$midtransOrderId/');
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
