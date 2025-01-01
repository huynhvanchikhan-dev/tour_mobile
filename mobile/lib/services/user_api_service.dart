import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tour_new_version/models/user_model.dart';

class UserApiService {
  final String baseUrl;

  UserApiService({required this.baseUrl});

  /// Lấy thông tin profile của user
  /// - Header Authorization: token
  /// - GET /api/v2/users/profile
  Future<UserModel> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/v2/users/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': "Bearer $token", // hoặc "Bearer $token" nếu server yêu cầu
      },
    );

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load user profile: ${response.body}');
    }
  }

  /// Cập nhật thông tin user
  /// - Header Authorization: token
  /// - Body: user.toJson()
  /// - POST /api/v2/users/update
  Future<UserModel> updateUserProfile(String token, UserModel user) async {
    final url = Uri.parse('$baseUrl/api/v2/users/update');
    final response = await http.post(
      url,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  /// Đổi mật khẩu
  /// - Header Authorization: token
  /// - Body: { "oldPassword":..., "newPassword":... }
  /// - POST /api/v2/users/change-password
  Future<void> changeUserPassword(String token, String oldPass, String newPass) async {
    final url = Uri.parse('$baseUrl/api/v2/users/change-password');
    final response = await http.post(
      url,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "oldPassword": oldPass,
        "newPassword": newPass,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change password: ${response.body}');
    }
    // Nếu = 200 thì OK.
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return data['token']; // Giả sử server trả về token trong phản hồi
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<String> registerUser(String email, String username, String password, String phoneNumber, String address) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'phone_number': phoneNumber,
        'address': address,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['email']; // Assuming the API returns this
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

 Future<String> verifyCode(String email, String code) async {
  final url = Uri.parse('$baseUrl/api/v1/auth/verify');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'verify_code': code}),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['token'];  // Trích xuất token từ phản hồi
  } else {
    throw Exception('Verification failed: ${response.body}');
  }
}
}
