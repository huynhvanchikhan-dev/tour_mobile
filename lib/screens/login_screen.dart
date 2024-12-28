import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:tour_booking/models/auth_manager.dart';
import 'package:tour_booking/screens/home_screen.dart';

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

  // Dùng Android client ID. LƯU Ý: Nếu cần idToken cho server, nên dùng Web client ID.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Thay = Android client ID (bạn vừa tạo): 
    // Nếu cần server verify => khuyên dùng Web client ID thay vì Android client ID.
    serverClientId: "161623696141-n3mg0s8lftr6u73i28fcms0r9664sboa.apps.googleusercontent.com",
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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

        final auth = context.read<AuthManager>();
        await auth.login(token);

        Navigator.of(context).pushReplacementNamed('/profile');
      } else {
        _error = "Đăng nhập thất bại: ${response.body}";
      }
    } catch (e) {
      _error = "Có lỗi xảy ra: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng cancel
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;   // Có thể null nếu serverClientId chưa là web client ID
      final accessToken = googleAuth.accessToken;

      // Debug
      print("idToken: $idToken");
      print("accessToken: $accessToken");

      if (idToken == null) {
        _error = "Không lấy được idToken từ Google (check serverClientId).";
        setState(() => _isLoading = false);
        return;
      }

      // Gửi idToken lên server (server đang validate token?)
      final response = await http.post(
        Uri.parse('http://192.168.1.5:8080/api/v1/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(idToken),
      );

      if (response.statusCode == 202 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final token = body['token'];

        final auth = context.read<AuthManager>();
        await auth.login(token);

       Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreen(),
                                          ),
                                        );
      } else {
        _error = "Đăng nhập Google thất bại: ${response.body}";
      }
    } catch (e) {
      _error = "Có lỗi khi đăng nhập Google: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/images/logo.png', // ví dụ icon google
                      height: 24,
                      width: 24,
                    ),
                    label: const Text("Login with Google"),
                    onPressed: _handleGoogleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
