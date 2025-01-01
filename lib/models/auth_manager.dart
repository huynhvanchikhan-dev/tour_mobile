import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthManager with ChangeNotifier {
  // SecureStorage để lưu token
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Biến lưu token hiện tại (nếu có)
  String? _jwtToken;

  // Cờ đánh dấu đã đăng nhập hay chưa
  bool _isLoggedIn = false;

  // Getter
  bool get isLoggedIn => _isLoggedIn;
  String? get jwtToken => _jwtToken;

  AuthManager() {
    // Mỗi khi khởi tạo AuthManager, ta đọc token từ storage
    _loadTokenFromStorage();
  }

  /// Đọc token đã lưu, kiểm tra hạn, và cập nhật trạng thái
  Future<void> _loadTokenFromStorage() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token != null) {
        // Nếu token chưa hết hạn, đánh dấu là đã đăng nhập
        if (!_isTokenExpired(token)) {
          _jwtToken = token;
          _isLoggedIn = true;
        } else {
          // Token hết hạn => xoá token
          await _secureStorage.delete(key: 'jwt_token');
        }
      }
      notifyListeners();
    } catch (e) {
      // Xử lý lỗi nếu cần
      debugPrint("Error loading token: $e");
    }
  }

  /// Hàm này để đăng nhập (lưu token)  
  Future<void> login(String token) async {
    try {
      if (!_isTokenExpired(token)) {
        _jwtToken = token;
        _isLoggedIn = true;
        await _secureStorage.write(key: 'jwt_token', value: token);
        notifyListeners();
      } else {
        throw Exception("Token is expired");
      }
    } catch (e) {
      debugPrint("Error on login: $e");
      rethrow;
    }
  }

  /// Đăng xuất, xoá token, cập nhật trạng thái
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'jwt_token');
      _jwtToken = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error on logout: $e");
      rethrow;
    }
  }

  /// Hàm check token còn valid hay không
  Future<bool> hasValidToken() async {
    if (_jwtToken == null) return false;
    return !_isTokenExpired(_jwtToken!);
  }

  // ------- HÀM HỖ TRỢ ------- //

  /// Kiểm tra xem token đã hết hạn chưa (dựa vào claim exp)
  bool _isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

//   void verifyAndLogin(String email, String code) async {
//   try {
//     final token = await userApi.verifyCode(email, code);
//     await authManager.login(token);  // Đăng nhập và lưu token
//     Navigator.of(context).pushReplacementNamed('/homeScreen');  // Chuyển đến màn hình chính
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//   }
// }
}
