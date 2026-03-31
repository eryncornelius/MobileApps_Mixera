import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../models/cart_item_model.dart';
import '../models/cart_summary_model.dart';

class CartRemoteDatasource {
  CartRemoteDatasource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _base,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;
  static const String _base = 'http://127.0.0.1:8000/api/cart';

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Gagal terhubung ke server.';
  }

  Future<Options> _auth() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<CartSummaryModel> getCart() async {
    try {
      final res = await _dio.get('/', options: await _auth());
      return CartSummaryModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<CartItemModel> addItem(int variantId, int quantity) async {
    try {
      final res = await _dio.post(
        '/items/',
        data: {'variant_id': variantId, 'quantity': quantity},
        options: await _auth(),
      );
      return CartItemModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<CartItemModel> updateItem(int id, int quantity) async {
    try {
      final res = await _dio.patch(
        '/items/$id/',
        data: {'quantity': quantity},
        options: await _auth(),
      );
      return CartItemModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> removeItem(int id) async {
    try {
      await _dio.delete('/items/$id/', options: await _auth());
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/clear/', options: await _auth());
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
