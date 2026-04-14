import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../models/category_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';

/// Katalog toko: endpoint umumnya publik; Dio tetap sama agar [API_BASE_URL] konsisten.
class ShopRemoteDatasource {
  ShopRemoteDatasource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiBaseUrl.module('shop'),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: const {'Accept': 'application/json'},
          ),
        ),
        _authDio = createAuthenticatedDio(
          baseUrl: ApiBaseUrl.module('shop'),
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        );

  final Dio _dio;
  final Dio _authDio;

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    return 'Gagal terhubung ke server.';
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _dio.get('/categories/');
      return (res.data as List)
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<ProductModel>> getProducts({String? search, String? category}) async {
    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (category != null && category.isNotEmpty) params['category'] = category;
      final res = await _dio.get('/products/', queryParameters: params);
      return (res.data as List)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ProductDetailModel> getProductDetail(String slug) async {
    try {
      final res = await _dio.get('/products/$slug/');
      return ProductDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<ProductModel>> getWishlist() async {
    try {
      final res = await _authDio.get('/wishlist/');
      return (res.data as List)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> toggleWishlist(int productId) async {
    try {
      final res = await _authDio.post(
        '/wishlist/toggle/',
        data: {'product_id': productId},
      );
      final map = Map<String, dynamic>.from(res.data as Map);
      return map['is_wishlisted'] as bool? ?? false;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
