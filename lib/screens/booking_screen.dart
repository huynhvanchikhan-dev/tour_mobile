import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tour_new_version/models/payment_request.dart';
import 'package:tour_new_version/models/tour_model.dart';
import 'package:tour_new_version/models/auth_manager.dart';
import 'package:tour_new_version/models/booking_request.dart';
import 'package:tour_new_version/repositories/payments.dart';
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
          ),
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
              paymentMethod: "paymentMethod"));
              print("booking respone: $order");
          if (order != null) {
            Navigator.pop(context);
            zpTransToken = order.zptranstoken;
            print("zpTransToken $zpTransToken'.");
            setState(() {
              zpTransToken = order.zptranstoken;
              showResult = true;
            });
            
            if(zpTransToken != null){
              String response1 = "";
              try {
                final String result = await platform.invokeMethod('payOrder', {"zptoken": zpTransToken});
                response1 = result;
                print("payOrder Result: '$result'.");
              } on PlatformException catch (e) {
                print("Failed to Invoke: '${e.message}'.");
                response1 = "Thanh toán thất bại";
              }
              print(response1);
              setState(() {
                payResult = response1;
              });
            }
          }
        }
      } catch (e) {
        
        print("Error processing booking: $e");
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
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              TextFormField(
                controller: _cinController,
                decoration: InputDecoration(labelText: 'Số CMND/CCCD'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập số CMND/CCCD' : null,
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
