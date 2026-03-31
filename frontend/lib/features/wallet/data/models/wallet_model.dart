class WalletModel {
  final int balance;
  final DateTime updatedAt;

  const WalletModel({required this.balance, required this.updatedAt});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: json['balance'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
