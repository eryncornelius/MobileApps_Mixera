class SavedCardModel {
  final int id;
  final String cardBrand;
  final String maskedCard;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;

  const SavedCardModel({
    required this.id,
    required this.cardBrand,
    required this.maskedCard,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) => SavedCardModel(
        id: json['id'] as int,
        cardBrand: json['card_brand'] as String? ?? '',
        maskedCard: json['masked_card'] as String? ?? '',
        expiryMonth: json['expiry_month'] as String? ?? '',
        expiryYear: json['expiry_year'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );

  String get displayLabel {
    final brand = cardBrand.isNotEmpty ? cardBrand.toUpperCase() : 'CARD';
    return '$brand  •••• ${maskedCard.length >= 4 ? maskedCard.substring(maskedCard.length - 4) : maskedCard}';
  }

  String get expiryLabel {
    if (expiryMonth.isEmpty || expiryYear.isEmpty) return '';
    final yy = expiryYear.length >= 2 ? expiryYear.substring(expiryYear.length - 2) : expiryYear;
    return 'Exp $expiryMonth/$yy';
  }
}
