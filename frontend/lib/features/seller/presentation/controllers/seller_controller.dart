import 'package:get/get.dart';

import '../../../shop/data/models/product_detail_model.dart';
import '../../../shop/data/models/product_model.dart';
import '../../data/datasources/seller_remote_datasource.dart';

class SellerController extends GetxController {
  final SellerRemoteDatasource _api = SellerRemoteDatasource();

  final storeName = ''.obs;
  /// Kode pos asal pengiriman (5 digit), dari profil seller.
  final shipFromPostalCode = ''.obs;
  final isLoadingMe = false.obs;

  final dashboard = Rxn<Map<String, dynamic>>();
  final isLoadingDashboard = false.obs;

  final products = <ProductModel>[].obs;
  final isLoadingProducts = false.obs;

  final orders = <Map<String, dynamic>>[].obs;
  final isLoadingOrders = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadMe(), loadDashboard(), loadProducts(), loadOrders()]);
  }

  Future<void> loadMe() async {
    isLoadingMe.value = true;
    try {
      final m = await _api.getMe();
      storeName.value = m['store_name'] as String? ?? '';
      shipFromPostalCode.value =
          m['ship_from_postal_code'] as String? ?? '';
    } catch (_) {
      storeName.value = '';
      shipFromPostalCode.value = '';
    } finally {
      isLoadingMe.value = false;
    }
  }

  Future<void> loadDashboard() async {
    isLoadingDashboard.value = true;
    try {
      dashboard.value = await _api.getDashboard();
    } catch (_) {
      dashboard.value = null;
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<void> saveStoreProfile({
    required String storeName,
    required String shipFromPostalCode,
  }) async {
    await _api.patchMe(
      storeName: storeName,
      shipFromPostalCode: shipFromPostalCode,
    );
    this.storeName.value = storeName;
    this.shipFromPostalCode.value = shipFromPostalCode;
  }

  Future<ProductDetailModel?> loadProductDetail(int id) async {
    try {
      return await _api.getSellerProduct(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadProducts() async {
    isLoadingProducts.value = true;
    try {
      products.assignAll(await _api.getMyProducts());
    } catch (_) {
      products.clear();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> loadOrders() async {
    isLoadingOrders.value = true;
    try {
      orders.assignAll(await _api.getOrders());
    } catch (_) {
      orders.clear();
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<String> uploadProductImage(String filePath) =>
      _api.uploadProductImage(filePath);

  Future<ProductModel> createProduct({
    required String name,
    required int price,
    int? discountPrice,
    String description = '',
    String color = '',
    int stock = 0,
    String imageUrl = '',
    List<Map<String, dynamic>>? variants,
  }) async {
    final p = await _api.createProduct(
      name: name,
      price: price,
      discountPrice: discountPrice,
      description: description,
      color: color,
      stock: stock,
      imageUrl: imageUrl,
      variants: variants,
    );
    await loadProducts();
    return p;
  }

  Future<void> updateProduct({
    required int id,
    String? name,
    int? price,
    int? discountPrice,
    bool clearDiscountPrice = false,
    String? description,
    String? color,
    bool? isActive,
    int? stock,
    String? imageUrl,
    List<Map<String, int>>? variantStocks,
    List<Map<String, dynamic>>? variantsAdd,
  }) async {
    await _api.patchProduct(
      id,
      name: name,
      price: price,
      discountPrice: discountPrice,
      clearDiscountPrice: clearDiscountPrice,
      description: description,
      color: color,
      stock: (variantStocks != null && variantStocks.isNotEmpty) ? null : stock,
      isActive: isActive,
      imageUrl: imageUrl,
      variantStocks: variantStocks,
      variantsAdd: variantsAdd,
    );
    await loadProducts();
  }

  Future<void> shipOrder(int orderId, {required String tracking, String courier = ''}) async {
    await _api.updateOrderShipping(
      orderId,
      trackingNumber: tracking,
      shippingCourier: courier,
      status: 'shipped',
    );
    await loadOrders();
    await loadDashboard();
  }

  Future<void> completeOrder(int orderId) async {
    await _api.updateOrderShipping(orderId, status: 'completed');
    await loadOrders();
    await loadDashboard();
  }

  Future<void> requestPayout(int amount) async {
    await _api.postPayout(amount);
    await loadDashboard();
  }
}
