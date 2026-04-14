class CheckoutRequestModel {
  final int addressId;
  final String paymentMethod;
  /// Ongkir tervalidasi server (setelah preview `/cart/shipping-quote/`). Null = pakai default backend.
  final int? deliveryFee;

  const CheckoutRequestModel({
    required this.addressId,
    required this.paymentMethod,
    this.deliveryFee,
  });

  Map<String, dynamic> toJson() => {
        'address_id': addressId,
        'payment_method': paymentMethod,
        if (deliveryFee != null) 'delivery_fee': deliveryFee,
      };
}
