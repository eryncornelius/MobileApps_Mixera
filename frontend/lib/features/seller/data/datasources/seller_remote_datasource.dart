import 'package:dio/dio.dart';

import '../../../../core/network/api_base_url.dart';
import '../../../../core/network/authenticated_dio.dart';
import '../../../shop/data/models/product_detail_model.dart';
import '../../../shop/data/models/product_model.dart';

class SellerRemoteDatasource {
  SellerRemoteDatasource()
      : _dio = createAuthenticatedDio(
          baseUrl: ApiBaseUrl.module('sellers'),
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        );

  final Dio _dio;

  String _err(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['detail'] != null) return d['detail'].toString();
    return 'Permintaan gagal.';
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _dio.get('/me/');
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<void> patchMe({
    required String storeName,
    required String shipFromPostalCode,
  }) async {
    try {
      await _dio.patch(
        '/me/',
        data: {
          'store_name': storeName,
          'ship_from_postal_code': shipFromPostalCode,
        },
      );
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await _dio.get('/dashboard/');
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<List<Map<String, dynamic>>> getFinanceEarnings({String? from, String? to}) async {
    try {
      final res = await _dio.get(
        '/finance/earnings/',
        queryParameters: {
          ...?from != null ? {'from': from} : null,
          ...?to != null ? {'to': to} : null,
        },
      );
      final list = res.data as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<List<Map<String, dynamic>>> getFinancePayouts() async {
    try {
      final res = await _dio.get('/finance/payouts/');
      final list = res.data as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<Map<String, dynamic>> postPayout(int amount) async {
    try {
      final res = await _dio.post(
        '/finance/payouts/',
        data: {'amount': amount},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<String> downloadEarningsCsv() async {
    try {
      final res = await _dio.get<String>(
        '/finance/earnings/export/',
        options: Options(
          headers: const {'Accept': 'text/csv'},
          responseType: ResponseType.plain,
        ),
      );
      return res.data ?? '';
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final res = await _dio.get('/notifications/');
      final list = res.data as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<void> markNotificationsRead({bool all = false, int? id}) async {
    if (!all && id == null) {
      throw Exception('id wajib jika all=false.');
    }
    try {
      await _dio.post(
        '/notifications/read/',
        data: all ? {'all': true} : {'id': id},
      );
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<Map<String, dynamic>> postShippingQuote({
    required int weightGrams,
    String destinationCity = '',
    String destinationPostalCode = '',
  }) async {
    try {
      final res = await _dio.post(
        '/shipping/quote/',
        data: {
          'weight_grams': weightGrams,
          'destination_city': destinationCity,
          if (destinationPostalCode.trim().isNotEmpty) 'destination_postal_code': destinationPostalCode.trim(),
        },
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<List<Map<String, dynamic>>> getChannelListings() async {
    try {
      final res = await _dio.get('/channels/');
      final list = res.data as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<Map<String, dynamic>> postChannelListing({
    required int productId,
    required String channel,
  }) async {
    try {
      final res = await _dio.post(
        '/channels/',
        data: {'product_id': productId, 'channel': channel},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<List<ProductModel>> getMyProducts() async {
    try {
      final res = await _dio.get('/products/');
      final list = res.data as List;
      return list
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<String> uploadProductImage(String filePath) async {
    try {
      final name = filePath.replaceAll('\\', '/').split('/').last;
      final form = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: name,
        ),
      });
      final res = await _dio.post<Map<String, dynamic>>(
        '/products/upload-image/',
        data: form,
      );
      final url = res.data?['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Respons server tidak valid.');
      }
      return url;
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<ProductModel> createProduct({
    required String name,
    required int price,
    String description = '',
    int? discountPrice,
    String color = '',
    int stock = 0,
    String size = 'M',
    String imageUrl = '',
    List<Map<String, dynamic>>? variants,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        ...?discountPrice != null ? {'discount_price': discountPrice} : null,
        'color': color,
        'stock': stock,
        'size': size,
        if (imageUrl.isNotEmpty) 'image_url': imageUrl,
      };
      if (variants != null && variants.isNotEmpty) {
        data['variants'] = variants;
      }
      final res = await _dio.post(
        '/products/',
        data: data,
      );
      return ProductModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<ProductDetailModel> getSellerProduct(int id) async {
    try {
      final res = await _dio.get('/products/$id/');
      return ProductDetailModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<ProductModel> patchProduct(
    int id, {
    String? name,
    int? price,
    int? discountPrice,
    bool clearDiscountPrice = false,
    String? description,
    String? color,
    int? stock,
    bool? isActive,
    String? imageUrl,
    List<Map<String, int>>? variantStocks,
    List<Map<String, dynamic>>? variantsAdd,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (price != null) data['price'] = price;
      if (discountPrice != null) data['discount_price'] = discountPrice;
      if (clearDiscountPrice) data['discount_price'] = null;
      if (description != null) data['description'] = description;
      if (color != null) data['color'] = color;
      if (stock != null) data['stock'] = stock;
      if (isActive != null) data['is_active'] = isActive;
      if (imageUrl != null && imageUrl.isNotEmpty) data['image_url'] = imageUrl;
      if (variantStocks != null && variantStocks.isNotEmpty) {
        data['variant_stocks'] = variantStocks
            .map((e) => {'variant_id': e['variant_id'], 'stock': e['stock']})
            .toList();
      }
      if (variantsAdd != null && variantsAdd.isNotEmpty) {
        data['variants_add'] = variantsAdd;
      }
      final res = await _dio.patch(
        '/products/$id/',
        data: data,
      );
      return ProductModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<List<Map<String, dynamic>>> getOrders({String? status}) async {
    try {
      final res = await _dio.get(
        '/orders/',
        queryParameters: {
          ...?status != null && status.isNotEmpty ? {'status': status} : null,
        },
      );
      return List<Map<String, dynamic>>.from(
        (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    try {
      final res = await _dio.get('/orders/$id/');
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<Map<String, dynamic>> updateOrderShipping(
    int id, {
    String? trackingNumber,
    String? shippingCourier,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (trackingNumber != null) body['tracking_number'] = trackingNumber;
      if (shippingCourier != null) body['shipping_courier'] = shippingCourier;
      if (status != null) body['status'] = status;
      final res = await _dio.patch(
        '/orders/$id/',
        data: body,
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }
}
