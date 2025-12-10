class User {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? phone;
  final bool isActive;
  final bool isVerified;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phone,
    required this.isActive,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      phone: json['phone'],
      isActive: json['is_active'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'phone': phone,
      'is_active': isActive,
      'is_verified': isVerified,
    };
  }
}
