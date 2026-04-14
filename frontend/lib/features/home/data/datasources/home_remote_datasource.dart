import '../models/dashboard_model.dart';
import '../models/quick_action_model.dart';
import '../models/recommendation_banner_model.dart';
import '../../../shop/data/datasources/shop_remote_datasource.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../wardrobe/data/datasources/wardrobe_remote_datasource.dart';
import '../../../wardrobe/data/models/wardrobe_api_models.dart';

abstract class HomeRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({
    WardrobeRemoteDatasource? wardrobe,
    ShopRemoteDatasource? shop,
  })  : _wardrobe = wardrobe ?? WardrobeRemoteDatasource(),
        _shop = shop ?? ShopRemoteDatasource();

  final WardrobeRemoteDatasource _wardrobe;
  final ShopRemoteDatasource _shop;

  static String _greetingByTime() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Future<DashboardModel> getDashboard() async {
    final wardrobeApi = await _safeWardrobeItems();
    final products = await _safeProducts();

    final wardrobeItems = wardrobeApi
        .take(4)
        .map(
          (w) => WardrobeItemModel(
            id: w.id.toString(),
            imageUrl: resolveMediaUrl(w.image),
            name: w.name.trim().isNotEmpty ? w.name : w.category,
          ),
        )
        .toList();

    final saleFromShop = products.where((p) => p.discountPrice != null).toList();
    final saleItems = saleFromShop
        .take(3)
        .map(_productToSale)
        .toList();

    final recommendedItems = products
        .take(6)
        .map(_productToRecommended)
        .toList();

    final banner = _buildBanner(wardrobeItems);

    return DashboardModel(
      greeting: _greetingByTime(),
      greetingSubtitle: 'Ready to style today?',
      featuredBanner: banner,
      quickActions: const [
        QuickActionModel(
          id: 'qa_1',
          label: 'Add Clothes',
          iconName: 'shirt',
          route: '/wardrobe/add',
        ),
        QuickActionModel(
          id: 'qa_2',
          label: 'Mix Ai',
          iconName: 'sparkles',
          route: '/mix',
        ),
        QuickActionModel(
          id: 'qa_3',
          label: 'Saved Outfits',
          iconName: 'bookmark',
          route: '/saved',
        ),
        QuickActionModel(
          id: 'qa_4',
          label: 'Orders',
          iconName: 'bag',
          route: '/orders',
        ),
      ],
      wardrobeItems: wardrobeItems,
      saleItems: saleItems,
      recommendedItems: recommendedItems,
    );
  }

  Future<List<WardrobeItemApiModel>> _safeWardrobeItems() async {
    try {
      return await _wardrobe.getWardrobeItems();
    } catch (_) {
      return [];
    }
  }

  Future<List<ProductModel>> _safeProducts() async {
    try {
      return await _shop.getProducts();
    } catch (_) {
      return [];
    }
  }

  RecommendationBannerModel _buildBanner(List<WardrobeItemModel> wardrobeItems) {
    const fallbackImage =
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400';
    if (wardrobeItems.isNotEmpty) {
      final first = wardrobeItems.first;
      return RecommendationBannerModel(
        id: 'banner_wardrobe',
        title: 'Style your look',
        subtitle: '${first.name}\nTap Mix Ai to combine outfits.',
        imageUrl: first.imageUrl.isNotEmpty ? first.imageUrl : fallbackImage,
        ctaLabel: 'Mix My Outfit',
        ctaRoute: '/mix',
      );
    }
    return const RecommendationBannerModel(
      id: 'banner_default',
      title: 'Mix My Outfit',
      subtitle: 'Soft pastel look\nfor a casual day',
      imageUrl: fallbackImage,
      ctaLabel: 'Mix My Outfit',
      ctaRoute: '/mix',
    );
  }

  SaleItemModel _productToSale(ProductModel p) {
    final orig = p.price.toDouble();
    final sale = p.discountPrice!.toDouble();
    final pct = p.discountPercent;
    return SaleItemModel(
      id: p.id.toString(),
      name: p.name,
      imageUrl: resolveMediaUrl(p.primaryImage),
      originalPrice: orig,
      salePrice: sale,
      discountPercent: pct,
    );
  }

  RecommendedItemModel _productToRecommended(ProductModel p) {
    return RecommendedItemModel(
      id: p.id.toString(),
      name: p.name,
      brand: p.categoryName ?? 'Mixéra Shop',
      imageUrl: resolveMediaUrl(p.primaryImage),
      price: p.displayPrice.toDouble(),
    );
  }
}
