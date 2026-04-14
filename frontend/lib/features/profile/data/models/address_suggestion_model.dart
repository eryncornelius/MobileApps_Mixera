class AddressSuggestionModel {
  final String fullAddress;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;

  const AddressSuggestionModel({
    required this.fullAddress,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory AddressSuggestionModel.fromNominatim(Map<String, dynamic> json) {
    final address = Map<String, dynamic>.from(json['address'] as Map? ?? const {});
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = address[k]?.toString().trim() ?? '';
        if (v.isNotEmpty) return v;
      }
      return '';
    }

    final road = pick(['road', 'pedestrian', 'footway', 'residential', 'path']);
    final houseNumber = pick(['house_number']);
    final neighbourhood = pick(['neighbourhood', 'suburb', 'village']);
    final streetParts = [houseNumber, road, neighbourhood].where((e) => e.isNotEmpty).toList();
    final street = streetParts.isNotEmpty ? streetParts.join(' ') : (json['display_name'] as String? ?? '');

    final city = pick(['city', 'town', 'municipality', 'county']);
    final state = pick(['state', 'region']);
    final postcode = pick(['postcode']);

    return AddressSuggestionModel(
      fullAddress: (json['display_name'] as String? ?? '').trim(),
      streetAddress: street.trim(),
      city: city,
      state: state,
      postalCode: postcode,
    );
  }
}
