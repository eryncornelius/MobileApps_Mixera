import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../../../checkout/data/models/order_model.dart';

class OrdersRemoteDatasource {
  OrdersRemoteDatasource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _base,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;
  static const String _base = 'http://127.0.0.1:8000/api/orders';

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Failed to load orders. Please try again.';
  }

  Future<Options> _auth() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final res = await _dio.get('/', options: await _auth());
      return (res.data as List)
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<OrderModel> getOrderDetail(int id) async {
    try {
      final res = await _dio.get('/$id/', options: await _auth());
      return OrderModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
