class CheckoutRequestModel {
  final int addressId;
  final String paymentMethod;

  const CheckoutRequestModel({
    required this.addressId,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'address_id': addressId,
        'payment_method': paymentMethod,
      };
}
