class ProductModel {
  final int id;
  final String name;
  final String slug;
  final int price;
  final int? discountPrice;
  final String? categoryName;
  final String? categorySlug;
  final String color;
  final bool isNew;
  final bool isActive;
  final bool moderationFlagged;
  final String moderationNote;
  final int totalStock;
  final String? primaryImage;
  final bool isWishlisted;

  const ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.discountPrice,
    this.categoryName,
    this.categorySlug,
    this.color = '',
    this.isNew = false,
    this.isActive = true,
    this.moderationFlagged = false,
    this.moderationNote = '',
    this.totalStock = 0,
    this.primaryImage,
    this.isWishlisted = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: json['price'] as int,
      discountPrice: json['discount_price'] as int?,
      categoryName: json['category_name'] as String?,
      categorySlug: json['category_slug'] as String?,
      color: json['color'] as String? ?? '',
      isNew: json['is_new'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      moderationFlagged: json['moderation_flagged'] as bool? ?? false,
      moderationNote: json['moderation_note'] as String? ?? '',
      totalStock: json['total_stock'] as int? ?? 0,
      primaryImage: json['primary_image'] as String?,
      isWishlisted: json['is_wishlisted'] as bool? ?? false,
    );
  }

  int get displayPrice => discountPrice ?? price;

  int get discountPercent {
    if (discountPrice == null || price == 0) return 0;
    return ((price - discountPrice!) / price * 100).round();
  }
}
