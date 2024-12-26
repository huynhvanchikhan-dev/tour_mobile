class UserModel {
  final String email;
  final String? username;
  final String? phone;
  final String? address;

  UserModel({required this.email, required this.username, required this.phone, required this.address});
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json["email"],
      username: json["username"],
      phone: json["phone"],
      address: json["address"],
    );
  }

}