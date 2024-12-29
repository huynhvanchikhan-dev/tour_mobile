import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_booking/models/auth_manager.dart';
import 'package:tour_booking/screens/home_screen.dart';
import 'package:tour_booking/services/user_api_service.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  VerifyScreen({required this.email});

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  // List of TextEditingControllers, one for each OTP digit.
  List<TextEditingController> _codeControllers = List.generate(4, (index) => TextEditingController());
  bool _isLoading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Concatenate the inputs from each controller to form the complete OTP code.
    String fullCode = _codeControllers.map((controller) => controller.text).join();
    try {
      final token =
          await Provider.of<UserApiService>(context, listen: false).verifyCode(
        widget.email,
        fullCode,
      );
      await Provider.of<AuthManager>(context, listen: false).login(token);
      Navigator.pushReplacement( // Use pushReplacement to avoid going back to the verification screen.
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Enter your OTP Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _otpInputField(index)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Verify"),
            ),
            if (_error != null) ...[
              SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _otpInputField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _codeControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.black12),
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          if (value.length == 1 && index != 3) {
            FocusScope.of(context).nextFocus(); // Move focus to next field.
          }
          if (value.isEmpty && index != 0) {
            FocusScope.of(context).previousFocus(); // Move focus to previous field if backspace is pressed.
          }
        },
      ),
    );
  }
}
