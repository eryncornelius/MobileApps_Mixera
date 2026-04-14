import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/checkout_request_model.dart';
import '../models/order_model.dart';

class CheckoutRemoteDatasource {
  CheckoutRemoteDatasource()
      : _dio = createAuthenticatedDio(baseUrl: ApiBaseUrl.module('orders'));

  final Dio _dio;

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Checkout failed. Please try again.';
  }

  Future<OrderModel> checkout(CheckoutRequestModel request) async {
    try {
      final res = await _dio.post(
        '/checkout/',
        data: request.toJson(),
      );
      return OrderModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final res = await _dio.get('/');
      return (res.data as List)
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
