import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../../../checkout/data/models/order_model.dart';
import '../models/tracking_model.dart';

class OrdersRemoteDatasource {
  OrdersRemoteDatasource()
      : _dio = createAuthenticatedDio(baseUrl: ApiBaseUrl.module('orders'));

  final Dio _dio;

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Failed to load orders. Please try again.';
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

  Future<OrderModel> getOrderDetail(int id) async {
    try {
      final res = await _dio.get('/$id/');
      return OrderModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<TrackingModel> getTracking(int orderId) async {
    try {
      final res = await _dio.get('/$orderId/tracking/');
      return TrackingModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
