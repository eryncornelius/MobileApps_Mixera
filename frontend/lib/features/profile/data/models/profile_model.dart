class ProfileModel {
  final int id;
  final String email;
  final String? pendingEmail;
  final String username;
  final String? phoneNumber;
  final String authProvider;
  final bool isEmailVerified;
  final bool isSeller;
  final String sellerStoreName;
  final bool isPremium;
  final String? premiumUntil;

  const ProfileModel({
    required this.id,
    required this.email,
    this.pendingEmail,
    required this.username,
    required this.phoneNumber,
    required this.authProvider,
    required this.isEmailVerified,
    required this.isSeller,
    required this.sellerStoreName,
    required this.isPremium,
    required this.premiumUntil,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      pendingEmail: json['pending_email'] as String?,
      username: json['username'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      authProvider: json['auth_provider'] as String? ?? 'email',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isSeller: json['is_seller'] as bool? ?? false,
      sellerStoreName: json['seller_store_name'] as String? ?? '',
      isPremium: json['is_premium'] as bool? ?? false,
      premiumUntil: json['premium_until'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {'username': username, 'phone_number': phoneNumber};
  }

  /// Login Google/Facebook — email placeholder backend tidak ditampilkan ke user.
  bool get isSocialAuth {
    final p = authProvider.toLowerCase();
    return p == 'google' || p == 'facebook';
  }

  String get socialProviderLabel {
    switch (authProvider.toLowerCase()) {
      case 'google':
        return 'Google';
      case 'facebook':
        return 'Facebook';
      default:
        return 'sosial';
    }
  }

  ProfileModel copyWith({
    int? id,
    String? email,
    String? pendingEmail,
    String? username,
    String? phoneNumber,
    String? authProvider,
    bool? isEmailVerified,
    bool? isSeller,
    String? sellerStoreName,
    bool? isPremium,
    String? premiumUntil,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      authProvider: authProvider ?? this.authProvider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isSeller: isSeller ?? this.isSeller,
      sellerStoreName: sellerStoreName ?? this.sellerStoreName,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
    );
  }
}
