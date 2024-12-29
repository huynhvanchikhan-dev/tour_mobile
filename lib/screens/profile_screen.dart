import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:tour_booking/models/auth_manager.dart';
import 'package:tour_booking/screens/home_screen.dart';

import '../models/user_model.dart';
import '../services/user_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  UserModel? _user;
  bool _isLoading = false;

  // Khởi tạo userApi
  late final UserApiService _userApi;

  @override
  void initState() {
    super.initState();
    _userApi = UserApiService(baseUrl: 'http://54.252.193.168:8080');
    _fetchUserProfile();
  }

  /// Gọi API GET profile
  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthManager>();
    final token = auth.jwtToken ?? '';

    try {
      final user = await _userApi.getUserProfile(token);
      setState(() {
        _user = user;
        _usernameCtrl.text = user.username;
        _phoneCtrl.text = user.phone;
        _cinCtrl.text = user.cin;
        _addressCtrl.text = user.address;
      });
    } catch (e) {
      debugPrint('Error fetch profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Gọi API POST update
  Future<void> _handleUpdateProfile() async {
    if (_user == null) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthManager>();
    final token = auth.jwtToken ?? '';

    // Tạo model mới từ form
    final updatedUser = UserModel(
      id: _user!.id,
      email: _user!.email,
      username: _usernameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      cin: _cinCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    try {
      final newUser = await _userApi.updateUserProfile(token, updatedUser);
      setState(() {
        _user = newUser;
        _usernameCtrl.text = newUser.username;
        _phoneCtrl.text = newUser.phone;
        _cinCtrl.text = newUser.cin;
        _addressCtrl.text = newUser.address;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công!')),
      );
    } catch (e) {
      debugPrint('Error update user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Đổi mật khẩu => mở Dialog
  void _handleChangePassword() {
    final auth = context.read<AuthManager>();
    final token = auth.jwtToken ?? '';

    showDialog(
      context: context,
      builder: (_) => ChangePasswordDialog(token: token),
    );
  }

  /// Đăng xuất => gọi auth.logout()
  void _handleLogout() async {
    await context.read<AuthManager>().logout();
    // Quay về màn hình chính (HomeScreen)
    Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreen(),
                                          ),
                                        );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LinearProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar + Email + Tên
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              "https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-17.jpg",
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _usernameCtrl.text,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _user?.email ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form update
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Thông tin cá nhân chi tiết",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: const InputDecoration(
                              labelText: "Họ và tên",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: "Số điện thoại",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _cinCtrl,
                            decoration: const InputDecoration(
                              labelText: "Số CMND/CCCD",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _addressCtrl,
                            decoration: const InputDecoration(
                              labelText: "Địa chỉ",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleUpdateProfile,
                                  child: const Text("Cập nhật thông tin"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _handleChangePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text("Đổi mật khẩu"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Dialog đổi mật khẩu
class ChangePasswordDialog extends StatefulWidget {
  final String token;
  const ChangePasswordDialog({Key? key, required this.token}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitChangePassword() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://192.168.1.5:8080/api/v2/users/change-password');
      final response = await http.post(
        url,
        headers: {
          'Authorization': widget.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "oldPassword": oldPass,
          "newPassword": newPass,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Đổi mật khẩu"),
      content: SizedBox(
        height: 180,
        child: Column(
          children: [
            TextField(
              controller: _oldPassCtrl,
              decoration: const InputDecoration(labelText: "Mật khẩu cũ"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPassCtrl,
              decoration: const InputDecoration(labelText: "Mật khẩu mới"),
              obscureText: true,
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitChangePassword,
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
