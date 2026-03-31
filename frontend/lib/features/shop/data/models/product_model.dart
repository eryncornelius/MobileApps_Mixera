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
  final String? primaryImage;

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
    this.primaryImage,
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
      primaryImage: json['primary_image'] as String?,
    );
  }

  int get displayPrice => discountPrice ?? price;

  int get discountPercent {
    if (discountPrice == null || price == 0) return 0;
    return ((price - discountPrice!) / price * 100).round();
  }
}
