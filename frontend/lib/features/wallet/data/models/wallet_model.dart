class WalletModel {
  final int balance;
  final DateTime updatedAt;

  const WalletModel({required this.balance, required this.updatedAt});

  static int _readInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: _readInt(json['balance']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
