class Address {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String street;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $ward, $district, $city';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      phone: json['phone'],
      street: json['street'],
      ward: json['ward'],
      district: json['district'],
      city: json['city'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? street,
    String? ward,
    String? district,
    String? city,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
