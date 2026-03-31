import 'package:get/get.dart';

import '../../data/datasources/shop_remote_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_detail_model.dart';
import '../../data/models/product_model.dart';

class ShopController extends GetxController {
  final _ds = ShopRemoteDatasource();

  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedCategorySlug = ''.obs;
  final isLoadingCategories = false.obs;
  final isLoadingProducts = false.obs;

  // Search page
  final searchResults = <ProductModel>[].obs;
  final isSearching = false.obs;
  final recentSearches = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      categories.value = await _ds.getCategories();
    } catch (_) {
      // silently ignore; shop still shows without categories
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchProducts({String? search, String? category}) async {
    isLoadingProducts.value = true;
    try {
      products.value = await _ds.getProducts(
        search: search,
        category: category,
      );
    } catch (_) {
      products.value = [];
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void selectCategory(String slug) {
    selectedCategorySlug.value = slug;
    fetchProducts(category: slug.isEmpty ? null : slug);
  }

  @override
  Future<void> refresh() async {
    await Future.wait([fetchCategories(), fetchProducts(category: selectedCategorySlug.value.isEmpty ? null : selectedCategorySlug.value)]);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResults.value = [];
      return;
    }
    isSearching.value = true;
    try {
      searchResults.value = await _ds.getProducts(search: query.trim());
      if (!recentSearches.contains(query.trim())) {
        recentSearches.insert(0, query.trim());
        if (recentSearches.length > 10) recentSearches.removeLast();
      }
    } catch (_) {
      searchResults.value = [];
    } finally {
      isSearching.value = false;
    }
  }

  void clearRecentSearches() => recentSearches.clear();

  Future<ProductDetailModel?> getProductDetail(String slug) async {
    try {
      return await _ds.getProductDetail(slug);
    } catch (_) {
      return null;
    }
  }
}
