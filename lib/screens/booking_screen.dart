import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tour_booking/models/tour_model.dart';
import 'package:tour_booking/models/auth_manager.dart';
import 'package:tour_booking/models/booking_request.dart';
import 'package:tour_booking/services/booking_api_service.dart';
import 'package:tour_booking/services/user_api_service.dart';
import 'package:tour_booking/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _guestSize = 1;

  @override
  void initState() {
    super.initState();
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
        UserModel user = await userService.getUserProfile(authManager.jwtToken!);
        _fullNameController.text = user.username;
        _phoneController.text = user.phone;
        _cinController.text = user.cin;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch user profile: $e')));
    }
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
        final bookingApiService = Provider.of<BookingApiService>(context, listen: false);
        final token = Provider.of<AuthManager>(context, listen: false).jwtToken ?? "";
        final bookingData = await bookingApiService.createBooking(
          BookingRequest(
            fullname: _fullNameController.text,
            phone: _phoneController.text,
            cin: _cinController.text,
            guestSize: _guestSize,
            amount: _guestSize * widget.tour.price,
            tour_id: widget.tour.id.toString(),
          ),
          token,
        );
        if (bookingData.isNotEmpty) {
          String bookingId = bookingData['bookingId'];
          String paymentUrl = await bookingApiService.initiatePayment(
            bookingId,
            'ZALOPAY', // or 'VNPAY'
            token,
          );
          if (await canLaunch(paymentUrl)) {
            await launch(paymentUrl);
          } else {
            throw 'Could not launch $paymentUrl';
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing booking: $e')),
        );
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
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Họ và tên'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              TextFormField(
                controller: _cinController,
                decoration: InputDecoration(labelText: 'Số CMND/CCCD'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập số CMND/CCCD' : null,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text('Số người: $_guestSize'),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (_guestSize > 1) {
                        setState(() {
                          _guestSize--;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _guestSize++;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _processBooking,
                child: Text('Đặt Tour Ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
