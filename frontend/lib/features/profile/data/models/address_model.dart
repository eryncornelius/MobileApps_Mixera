class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final bool isPrimary;

  const AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.isPrimary,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      label: json['label'] as String? ?? 'home',
      recipientName: json['recipient_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      streetAddress: json['street_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'recipient_name': recipientName,
      'phone_number': phoneNumber,
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'is_primary': isPrimary,
    };
  }

  AddressModel copyWith({
    int? id,
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    bool? isPrimary,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}