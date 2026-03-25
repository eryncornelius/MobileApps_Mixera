import 'quick_action_model.dart';
import 'recommendation_banner_model.dart';

class WardrobeItemModel {
  final String id;
  final String imageUrl;
  final String name;

  const WardrobeItemModel({
    required this.id,
    required this.imageUrl,
    required this.name,
  });

  factory WardrobeItemModel.fromJson(Map<String, dynamic> json) {
    return WardrobeItemModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      name: json['name'] as String,
    );
  }
}

class SaleItemModel {
  final String id;
  final String name;
  final String imageUrl;
  final double originalPrice;
  final double salePrice;
  final int discountPercent;

  const SaleItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercent,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      originalPrice: (json['original_price'] as num).toDouble(),
      salePrice: (json['sale_price'] as num).toDouble(),
      discountPercent: json['discount_percent'] as int,
    );
  }
}

class RecommendedItemModel {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double price;

  const RecommendedItemModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.price,
  });

  factory RecommendedItemModel.fromJson(Map<String, dynamic> json) {
    return RecommendedItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class DashboardModel {
  final String greeting;
  final String greetingSubtitle;
  final RecommendationBannerModel featuredBanner;
  final List<QuickActionModel> quickActions;
  final List<WardrobeItemModel> wardrobeItems;
  final List<SaleItemModel> saleItems;
  final List<RecommendedItemModel> recommendedItems;

  const DashboardModel({
    required this.greeting,
    required this.greetingSubtitle,
    required this.featuredBanner,
    required this.quickActions,
    required this.wardrobeItems,
    required this.saleItems,
    required this.recommendedItems,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      greeting: json['greeting'] as String,
      greetingSubtitle: json['greeting_subtitle'] as String,
      featuredBanner: RecommendationBannerModel.fromJson(
        json['featured_banner'] as Map<String, dynamic>,
      ),
      quickActions: (json['quick_actions'] as List)
          .map((e) => QuickActionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      wardrobeItems: (json['wardrobe_items'] as List)
          .map((e) => WardrobeItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      saleItems: (json['sale_items'] as List)
          .map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedItems: (json['recommended_items'] as List)
          .map((e) => RecommendedItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
