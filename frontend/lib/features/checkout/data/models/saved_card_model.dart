class SavedCardModel {
  final int id;
  final String cardBrand;
  final String maskedCard;
  final bool isDefault;

  const SavedCardModel({
    required this.id,
    required this.cardBrand,
    required this.maskedCard,
    required this.isDefault,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) => SavedCardModel(
        id: json['id'] as int,
        cardBrand: json['card_brand'] as String? ?? '',
        maskedCard: json['masked_card'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );

  String get displayLabel {
    final brand = cardBrand.isNotEmpty ? cardBrand.toUpperCase() : 'CARD';
    return '$brand  •••• ${maskedCard.length >= 4 ? maskedCard.substring(maskedCard.length - 4) : maskedCard}';
  }
}
