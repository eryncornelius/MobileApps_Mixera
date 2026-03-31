class CartItemModel {
  final int id;
  final int variantId;
  final String productName;
  final String productSlug;
  final String size;
  final String color;
  final String? primaryImage;
  final int quantity;
  final int unitPrice;
  final int lineTotal;

  const CartItemModel({
    required this.id,
    required this.variantId,
    required this.productName,
    required this.productSlug,
    required this.size,
    required this.color,
    this.primaryImage,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      variantId: json['variant'] as int,
      productName: json['product_name'] as String? ?? '',
      productSlug: json['product_slug'] as String? ?? '',
      size: json['size'] as String? ?? '',
      color: json['color'] as String? ?? '',
      primaryImage: json['primary_image'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as int,
      lineTotal: json['line_total'] as int,
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      variantId: variantId,
      productName: productName,
      productSlug: productSlug,
      size: size,
      color: color,
      primaryImage: primaryImage,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      lineTotal: quantity != null ? unitPrice * quantity : lineTotal,
    );
  }
}
