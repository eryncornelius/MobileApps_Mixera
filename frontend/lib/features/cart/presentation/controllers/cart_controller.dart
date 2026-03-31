import 'package:get/get.dart';

import '../../data/datasources/cart_local_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_summary_model.dart';

class CartController extends GetxController {
  final _ds = CartRemoteDatasource();

  final cart = Rxn<CartSummaryModel>();
  final isLoading = false.obs;
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    isLoading.value = true;
    try {
      cart.value = await _ds.getCart();
    } catch (_) {
      cart.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(int variantId, int quantity) async {
    isUpdating.value = true;
    try {
      await _ds.addItem(variantId, quantity);
      await fetchCart();
    } catch (_) {
      // ignore
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    isUpdating.value = true;
    try {
      await _ds.updateItem(itemId, quantity);
      await fetchCart();
    } catch (_) {
      // ignore
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> removeItem(int itemId) async {
    isUpdating.value = true;
    try {
      await _ds.removeItem(itemId);
      await fetchCart();
    } catch (_) {
      // ignore
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> clearCart() async {
    isUpdating.value = true;
    try {
      await _ds.clearCart();
      cart.value = null;
    } catch (_) {
      // ignore
    } finally {
      isUpdating.value = false;
    }
  }

  int get itemCount => cart.value?.count ?? 0;
  int get total => cart.value?.total ?? 0;
  List<CartItemModel> get items => cart.value?.items ?? [];
}
