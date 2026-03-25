class RecommendationBannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaLabel;
  final String? ctaRoute;

  const RecommendationBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaLabel,
    this.ctaRoute,
  });

  factory RecommendationBannerModel.fromJson(Map<String, dynamic> json) {
    return RecommendationBannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String,
      ctaLabel: json['cta_label'] as String,
      ctaRoute: json['cta_route'] as String?,
    );
  }
}
