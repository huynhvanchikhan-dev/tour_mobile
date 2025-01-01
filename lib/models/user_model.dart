class UserModel {
  final String? id;
  final String? email;
  final String username;
  final String phone;
  final String address;
  final String cin;

  UserModel({
    this.id,
    this.email,
    required this.username,
    required this.phone,
    required this.address,
    required this.cin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      cin: json['cin'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "phone": phone,
      "address": address,
      "cin": cin,
    };
  }
}
