class DeliveryAddress {
  final String id;
  final String fullName;
  final String mobile;
  final String pincode;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final String state;
  final String addressType; // Home | Farm | Other
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.pincode,
    required this.addressLine1,
    this.addressLine2 = '',
    this.landmark = '',
    required this.city,
    required this.state,
    this.addressType = 'Home',
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get formatted {
    final parts = [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      if (landmark.isNotEmpty) landmark,
      city,
      '$state - $pincode',
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'mobile': mobile,
        'pincode': pincode,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'landmark': landmark,
        'city': city,
        'state': state,
        'addressType': addressType,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> j) => DeliveryAddress(
        id: j['id'] as String,
        fullName: j['fullName'] as String,
        mobile: j['mobile'] as String,
        pincode: j['pincode'] as String,
        addressLine1: j['addressLine1'] as String,
        addressLine2: (j['addressLine2'] as String?) ?? '',
        landmark: (j['landmark'] as String?) ?? '',
        city: j['city'] as String,
        state: j['state'] as String,
        addressType: (j['addressType'] as String?) ?? 'Home',
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        isDefault: (j['isDefault'] as bool?) ?? false,
      );

  DeliveryAddress copyWith({
    String? fullName,
    String? mobile,
    String? pincode,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? addressType,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) =>
      DeliveryAddress(
        id: id,
        fullName: fullName ?? this.fullName,
        mobile: mobile ?? this.mobile,
        pincode: pincode ?? this.pincode,
        addressLine1: addressLine1 ?? this.addressLine1,
        addressLine2: addressLine2 ?? this.addressLine2,
        landmark: landmark ?? this.landmark,
        city: city ?? this.city,
        state: state ?? this.state,
        addressType: addressType ?? this.addressType,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isDefault: isDefault ?? this.isDefault,
      );
}
