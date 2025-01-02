import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tour_new_version/models/payment_request.dart';
import 'package:tour_new_version/models/tour_model.dart';
import 'package:tour_new_version/models/auth_manager.dart';
import 'package:tour_new_version/models/booking_request.dart';
import 'package:tour_new_version/repositories/payments.dart';
import 'package:tour_new_version/screens/order_details_screen.dart';
import 'package:tour_new_version/services/booking_api_service.dart';
import 'package:tour_new_version/services/user_api_service.dart';
import 'package:tour_new_version/models/user_model.dart';

class BookingScreen extends StatefulWidget {
  final Tour tour;

  const BookingScreen({Key? key, required this.tour}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cinController;
  UserModel? user;
  int _guestSize = 1;
  static const EventChannel eventChannel =
      EventChannel('flutter.native/eventPayOrder');
  static const MethodChannel platform =
      MethodChannel('flutter.native/channelPayOrder');
  String zpTransToken = "";
  String payResult = "";
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    }

    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _cinController = TextEditingController();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final authManager = Provider.of<AuthManager>(context, listen: false);
      final userService = Provider.of<UserApiService>(context, listen: false);
      if (authManager.isLoggedIn && authManager.jwtToken != null) {
        user = await userService.getUserProfile(authManager.jwtToken!);
        _fullNameController.text = user!.username;
        _phoneController.text = user!.phone;
        _cinController.text = user!.cin;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user profile: $e')));
    }
  }

  void _onEvent(dynamic event) {
    // Changed Object to dynamic
    print("_onEvent: '$event'.");
    if (event is Map<dynamic, dynamic>) {
      // Make sure the Map check is also explicitly dynamic
      var res = Map<String, dynamic>.from(event);
      setState(() {
        if (res["errorCode"] == 1) {
          payResult = "Thanh toán thành công";
        } else if (res["errorCode"] == 4) {
          payResult = "User hủy thanh toán";
        } else {
          payResult = "Giao dịch thất bại";
        }
      });
    } else {
      print("Received event is not a Map");
    }
  }

  void _onError(Object? error) {
    // Make sure error can be nullable
    print("_onError: '${error.toString()}'.");
    setState(() {
      payResult = "Giao dịch thất bại";
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cinController.dispose();
    super.dispose();
  }

  void _processBooking() async {
    if (_formKey.currentState!.validate()) {
      try {
        final bookingApiService =
            Provider.of<BookingApiService>(context, listen: false);
        final token =
            Provider.of<AuthManager>(context, listen: false).jwtToken ?? "";
        final bookingData = await bookingApiService.createBooking(
          BookingRequest(
              fullname: _fullNameController.text,
              phone: _phoneController.text,
              cin: _cinController.text,
              guestSize: _guestSize,
              amount: _guestSize * widget.tour.price,
              tour_id: widget.tour.id.toString(),
              paymentMethod: "ZALOPAY"),
          token,
        );
        print(bookingData.toString());
        if (bookingData.isNotEmpty) {
          String bookingId = bookingData['id'];
          print("bookingId $bookingId");
          String response = "";
          final order = await createOrder(PaymentRequest(
              bookingId: bookingId,
              appuser: _fullNameController.text,
              amount: _guestSize * widget.tour.price,
              order_id: "order_id",
              qrUrl: "qrUrl",
              paymentMethod: "ZALOPAY"));
          print("booking respone: $order");
          if (order != null) {
            try {
              // Invoke ZaloPay payment
              final result = await platform.invokeMethod(
                'payOrder',
                {"zptoken": order.zptranstoken},
              );
              // Handle successful payment
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(
                    bookingData: bookingData,
                  ),
                ),
              );
            } catch (e) {
              // Handle payment failure
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(
                    bookingData: bookingData,
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        print("Error processing booking: $e");
      }
    }
  }

  Future<void> _processDirectPayment() async {
    if (_formKey.currentState!.validate()) {
      try {
        final bookingApiService =
            Provider.of<BookingApiService>(context, listen: false);
        final token =
            Provider.of<AuthManager>(context, listen: false).jwtToken ?? "";

        final bookingData = await bookingApiService.createBooking(
          BookingRequest(
              fullname: _fullNameController.text,
              phone: _phoneController.text,
              cin: _cinController.text,
              guestSize: _guestSize,
              amount: _guestSize * widget.tour.price,
              tour_id: widget.tour.id.toString(),
              paymentMethod: "NOTPAIED"),
          token,
        );

        if (bookingData.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                bookingData: bookingData,
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error processing direct payment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt Tour'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Thông tin đặt tour",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _cinController,
                decoration: InputDecoration(
                  labelText: 'Số CMND/CCCD',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập số CMND/CCCD' : null,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_guestSize > 1) {
                        setState(() {
                          _guestSize--;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xff4DA1A9), width: 2),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.remove,
                        color: Color(0xff4DA1A9),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 80,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_guestSize',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _guestSize++;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xff4DA1A9), width: 2),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.add,
                        color: Color(0xff4DA1A9),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _processBooking,
                      child: Text(
                        'ZaloPay',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            Color(0xff4DA1A9), // Nền giống LoginScreen
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _processDirectPayment,
                      child: Text(
                        'Thanh toán trực tiếp',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            Color(0xff4DA1A9), // Nền giống LoginScreen
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
