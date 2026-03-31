class CardChargeResultModel {
  final String midtransOrderId;
  final String transactionStatus;
  final String? fraudStatus;
  final int? linkedOrderId;
  final String? redirectUrl;

  const CardChargeResultModel({
    required this.midtransOrderId,
    required this.transactionStatus,
    this.fraudStatus,
    this.linkedOrderId,
    this.redirectUrl,
  });

  bool get isSuccess =>
      (transactionStatus == 'capture' || transactionStatus == 'settlement') &&
      (fraudStatus == 'accept' || fraudStatus == null || fraudStatus!.isEmpty);

  bool get needs3DS => transactionStatus == 'pending' && redirectUrl != null;

  bool get isFailed =>
      transactionStatus == 'deny' ||
      transactionStatus == 'failure' ||
      transactionStatus == 'cancel';

  factory CardChargeResultModel.fromJson(Map<String, dynamic> json) =>
      CardChargeResultModel(
        midtransOrderId: json['order_id'] as String? ?? '',
        transactionStatus: json['transaction_status'] as String? ?? 'pending',
        fraudStatus: json['fraud_status'] as String?,
        linkedOrderId: json['linked_order_id'] as int?,
        redirectUrl: json['redirect_url'] as String?,
      );
}
