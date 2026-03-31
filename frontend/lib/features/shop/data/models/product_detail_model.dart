import 'product_model.dart';

class ProductImageModel {
  final int id;
  final String imageUrl;
  final bool isPrimary;

  const ProductImageModel({required this.id, required this.imageUrl, this.isPrimary = false});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) => ProductImageModel(
        id: json['id'] as int,
        imageUrl: json['image_url'] as String,
        isPrimary: json['is_primary'] as bool? ?? false,
      );
}

class ProductVariantModel {
  final int id;
  final String size;
  final int stock;
  final String? sku;

  const ProductVariantModel({required this.id, required this.size, required this.stock, this.sku});

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) => ProductVariantModel(
        id: json['id'] as int,
        size: json['size'] as String,
        stock: json['stock'] as int,
        sku: json['sku'] as String?,
      );
}

class ProductDetailModel extends ProductModel {
  final String description;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  const ProductDetailModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.price,
    super.discountPrice,
    super.categoryName,
    super.categorySlug,
    super.color,
    super.isNew,
    super.primaryImage,
    required this.description,
    required this.images,
    required this.variants,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List? ?? [])
        .map((e) => ProductImageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final primaryImg = images.firstWhere(
      (i) => i.isPrimary,
      orElse: () => images.isNotEmpty ? images.first : const ProductImageModel(id: 0, imageUrl: ''),
    ).imageUrl;

    final cat = json['category'] as Map<String, dynamic>?;

    return ProductDetailModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: json['price'] as int,
      discountPrice: json['discount_price'] as int?,
      categoryName: cat?['name'] as String?,
      categorySlug: cat?['slug'] as String?,
      color: json['color'] as String? ?? '',
      isNew: json['is_new'] as bool? ?? false,
      primaryImage: primaryImg.isEmpty ? null : primaryImg,
      description: json['description'] as String? ?? '',
      images: images,
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariantModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
