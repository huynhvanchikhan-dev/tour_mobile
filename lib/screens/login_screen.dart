import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:tour_booking/models/auth_manager.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; _error = null; });

    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:8080/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 202) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        
        // Gọi provider để login
        final auth = context.read<AuthManager>();
        await auth.login(token);

        // Sau khi login thành công => pop or push screen khác
        Navigator.of(context).pop(); // Hoặc Navigator.pushReplacement(...)
      } else {
        _error = "Đăng nhập thất bại: ${response.body}";
      }
    } catch (e) {
      _error = "Có lỗi xảy ra: $e";
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: _passController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
    );
  }
}
