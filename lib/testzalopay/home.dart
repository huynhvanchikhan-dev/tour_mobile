import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:tour_new_version/models/payment_request.dart';
import 'package:tour_new_version/repositories/payments.dart';

class Home extends StatefulWidget {
  final String title;

  Home(this.title);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const EventChannel eventChannel = EventChannel('flutter.native/eventPayOrder');
  static const MethodChannel platform = MethodChannel('flutter.native/channelPayOrder');
  final textStyle = TextStyle(color: Colors.black54);
  final valueStyle = TextStyle(
      color: Colors.amber, fontSize: 18.0, fontWeight: FontWeight.w400);
  String zpTransToken = "";
  String payResult = "";
  String payAmount = "10000";
  bool showResult = false;
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
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

  // Button Create Order
  Widget _btnCreateOrder(String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: GestureDetector(
          onTap: () async {
            int amount = int.parse(value);
            if (amount < 1000 || amount > 1000000) {
              setState(() {
                zpTransToken = "Invalid Amount";
              });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  });
              var result = await createOrder(
                PaymentRequest(
                  bookingId: "112",
                  appuser: "test",
                  amount: 3 * 10000,
                  order_id: "order_id",
                  qrUrl: "qrUrl",
                  paymentMethod: "paymentMethod")
              );
              if (result != null) {
                Navigator.pop(context);
                zpTransToken = result.zptranstoken;
                setState(() {
                  zpTransToken = result.zptranstoken;
                  showResult = true;
                });
              }
            }
          },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Create Order",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      );

  /// Build Button Pay
  Widget _btnPay(String zpToken) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Visibility(
        visible: showResult,
        child: GestureDetector(
          onTap: () async {
            String response = "";
            try {
              final String result = await platform.invokeMethod('payOrder', {"zptoken": zpToken});
              response = result;
              print("payOrder Result: '$result'.");
            } on PlatformException catch (e) {
              print("Failed to Invoke: '${e.message}'.");
              response = "Thanh toán thất bại";
            }
            print(response);
            setState(() {
              payResult = response;
            });
          },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Pay",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _quickConfig,
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Amount',
            icon: Icon(Icons.attach_money),
          ),
          initialValue: payAmount,
          onChanged: (value) {
            setState(() {
              payAmount = value;
            });
          },
          keyboardType: TextInputType.number,
        ),
        _btnCreateOrder(payAmount),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Visibility(
            child: Text(
              "zptranstoken:",
              style: textStyle,
            ),
            visible: showResult,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            zpTransToken,
            style: valueStyle,
          ),
        ),
        _btnPay(zpTransToken),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Visibility(
              child: Text("Transaction status:", style: textStyle),
              visible: showResult),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            payResult,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

/// Build Info App
Widget _quickConfig = Container(
  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text("AppID: 2554"),
          ),
        ],
      ),
      // _btnQuickEdit,
    ],
  ),
);
