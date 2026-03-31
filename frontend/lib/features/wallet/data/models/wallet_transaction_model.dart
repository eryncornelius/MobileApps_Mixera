class WalletTransactionModel {
  final int id;
  final String type;
  final int amount;
  final String? reference;
  final String? description;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.reference,
    this.description,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: json['amount'] as int,
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isTopUp => type == 'top_up';
}
