import 'package:dio/dio.dart';

import '../models/category_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';

class ShopRemoteDatasource {
  ShopRemoteDatasource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _base,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;
  static const String _base = 'http://127.0.0.1:8000/api/shop';

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
}
