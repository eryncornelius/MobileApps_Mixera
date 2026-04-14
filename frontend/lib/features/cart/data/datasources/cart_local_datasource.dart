import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/cart_item_model.dart';
import '../models/cart_summary_model.dart';

class CartRemoteDatasource {
  CartRemoteDatasource()
      : _dio = createAuthenticatedDio(baseUrl: ApiBaseUrl.module('cart'));

  final Dio _dio;

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Gagal terhubung ke server.';
  }

  Future<CartSummaryModel> getCart() async {
    try {
      final res = await _dio.get('/');
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
      );
      return CartItemModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> removeItem(int id) async {
    try {
      await _dio.delete('/items/$id/');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/clear/');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// [addressId] atau [destinationPostalCode] — backend sama seperti seller/Biteship.
  Future<Map<String, dynamic>> postShippingQuote({
    int? addressId,
    String? destinationPostalCode,
  }) async {
    final body = <String, dynamic>{};
    if (addressId != null) body['address_id'] = addressId;
    final pc = destinationPostalCode?.trim() ?? '';
    if (pc.isNotEmpty) body['destination_postal_code'] = pc;
    try {
      final res = await _dio.post(
        '/shipping-quote/',
        data: body,
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
