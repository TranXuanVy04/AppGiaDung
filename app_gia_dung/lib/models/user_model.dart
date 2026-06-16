class UserModel {
  final int id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'Customer',
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
    };
  }

  factory UserModel.fromStorage(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      token: json['token'],
    );
  }
}