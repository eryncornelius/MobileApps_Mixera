class OrderItemModel {
  final int id;
  final String productName;
  final String productSlug;
  final String variantSize;
  final String color;
  final String primaryImage;
  final int unitPrice;
  final int quantity;
  final int lineTotal;

  const OrderItemModel({
    required this.id,
    required this.productName,
    required this.productSlug,
    required this.variantSize,
    required this.color,
    required this.primaryImage,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as int,
        productName: json['product_name'] as String? ?? '',
        productSlug: json['product_slug'] as String? ?? '',
        variantSize: json['variant_size'] as String? ?? '',
        color: json['color'] as String? ?? '',
        primaryImage: json['primary_image'] as String? ?? '',
        unitPrice: json['unit_price'] as int,
        quantity: json['quantity'] as int,
        lineTotal: json['line_total'] as int,
      );
}

/// Maps legacy API values to canonical slugs used in the app UI.
String _normalizeOrderStatus(String raw) {
  switch (raw) {
    case 'completed':
      return 'delivered';
    case 'cancelled':
      return 'canceled';
    default:
      return raw;
  }
}

class OrderModel {
  final int id;
  final String status;
  final int subtotal;
  final int deliveryFee;
  final int discountTotal;
  final int total;
  final String paymentMethod;
  final String paymentStatus;
  final String trackingNumber;
  final String shippingCourier;
  final Map<String, dynamic>? addressSnapshot;
  final String createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountTotal,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.trackingNumber = '',
    this.shippingCourier = '',
    this.addressSnapshot,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int,
        status: _normalizeOrderStatus(json['status'] as String? ?? ''),
        subtotal: json['subtotal'] as int,
        deliveryFee: json['delivery_fee'] as int,
        discountTotal: json['discount_total'] as int,
        total: json['total'] as int,
        paymentMethod: json['payment_method'] as String,
        paymentStatus: json['payment_status'] as String,
        trackingNumber: json['tracking_number'] as String? ?? '',
        shippingCourier: json['shipping_courier'] as String? ?? '',
        addressSnapshot: json['address_snapshot'] as Map<String, dynamic>?,
        createdAt: json['created_at'] as String? ?? '',
        items: (json['items'] as List? ?? [])
            .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
