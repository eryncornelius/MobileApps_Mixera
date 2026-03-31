import 'cart_item_model.dart';

class CartSummaryModel {
  final List<CartItemModel> items;
  final int total;
  final int count;

  const CartSummaryModel({
    required this.items,
    required this.total,
    required this.count,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      items: (json['items'] as List? ?? [])
          .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: json['total'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}
