class ProfileModel {
  final int id;
  final String email;
  final String username;
  final String? phoneNumber;
  final String authProvider;
  final bool isEmailVerified;
  final bool isPremium;
  final String? premiumUntil;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.authProvider,
    required this.isEmailVerified,
    required this.isPremium,
    required this.premiumUntil,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      authProvider: json['auth_provider'] as String? ?? 'email',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumUntil: json['premium_until'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {'username': username, 'phone_number': phoneNumber};
  }

  ProfileModel copyWith({
    int? id,
    String? email,
    String? username,
    String? phoneNumber,
    String? authProvider,
    bool? isEmailVerified,
    bool? isPremium,
    String? premiumUntil,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      authProvider: authProvider ?? this.authProvider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
    );
  }
}
