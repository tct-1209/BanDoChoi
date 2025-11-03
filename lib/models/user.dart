enum UserRole {
  customer,
  admin,
}

class User {
  final int id;
  final String phoneNumber;
  final String password;
  final String fullname;
  final String? address;
  final String roleName;
  final DateTime createdAt;
  final String email;
  final String? resetToken;
  final DateTime? resetTokenExpires;

  User({
    required this.id,
    required this.phoneNumber,
    required this.password,
    required this.fullname,
    this.address,
    required this.roleName,
    required this.createdAt,
    required this.email,
    this.resetToken,
    this.resetTokenExpires,
  });

  // Helper getter để check role
  bool get isAdmin => roleName == 'admin';
  bool get isCustomer => roleName == 'customer';

  // Helper getter để get UserRole enum
  UserRole get role {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      password: json['password'] ?? '',
      fullname: json['fullname'] ?? '',
      address: json['address'],
      roleName: json['role_name'] ?? 'customer',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      email: json['email'] ?? '',
      resetToken: json['reset_token'],
      resetTokenExpires: json['reset_token_expires'] != null 
          ? DateTime.parse(json['reset_token_expires']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'password': password,
      'fullname': fullname,
      'address': address,
      'role_name': roleName,
      'created_at': createdAt.toIso8601String(),
      'email': email,
      'reset_token': resetToken,
      'reset_token_expires': resetTokenExpires?.toIso8601String(),
    };
  }

  // Helper method để convert sang format cũ (nếu cần)
  Map<String, dynamic> toLegacyJson() {
    return {
      'id': id.toString(),
      'email': email,
      'name': fullname,
      'phone': phoneNumber,
      'avatar': null,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? phoneNumber,
    String? password,
    String? fullname,
    String? address,
    String? roleName,
    DateTime? createdAt,
    String? email,
    String? resetToken,
    DateTime? resetTokenExpires,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      fullname: fullname ?? this.fullname,
      address: address ?? this.address,
      roleName: roleName ?? this.roleName,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      resetToken: resetToken ?? this.resetToken,
      resetTokenExpires: resetTokenExpires ?? this.resetTokenExpires,
    );
  }
}
