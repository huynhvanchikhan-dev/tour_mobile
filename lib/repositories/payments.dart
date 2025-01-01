import 'dart:convert';

import 'package:sprintf/sprintf.dart';
import 'package:tour_new_version/models/booking_request.dart';
import 'package:tour_new_version/models/create_order_response.dart';
import 'package:tour_new_version/models/payment_request.dart';
import 'package:tour_new_version/utils/endpoints.dart';
import 'package:tour_new_version/utils/util.dart' as utils;
import 'package:http/http.dart' as http;
import 'dart:async';

class ZaloPayConfig {
  static const String appId = "2554";
  static const String key1 = "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn";
  static const String key2 = "trMrHtvjo6myautxDUiAcYsVtaeQ8nhf";

  static const String appUser = "";
  static int transIdDefault = 1;
}

Future<CreateOrderResponse?> createOrder(PaymentRequest request) async {
  var header = new Map<String, String>();
  header["Content-Type"] = "application/x-www-form-urlencoded";

  var body = new Map<String, String>();
  body["app_id"] = ZaloPayConfig.appId;
  body["app_user"] = request.appuser;
  body["app_time"] = DateTime.now().millisecondsSinceEpoch.toString();
  body["amount"] = request.amount.toStringAsFixed(0);
  body["app_trans_id"] = utils.getAppTransId();
  body["embed_data"] = "{}";
  body["item"] = "[]";
  body["bank_code"] = utils.getBankCode();
  body["description"] = utils.getDescription(body["app_trans_id"]!);

  var dataGetMac = sprintf("%s|%s|%s|%s|%s|%s|%s", [
    body["app_id"],
    body["app_trans_id"],
    body["app_user"],
    body["amount"],
    body["app_time"],
    body["embed_data"],
    body["item"]
  ]);
  body["mac"] = utils.getMacCreateOrder(dataGetMac);
  print("mac: ${body["mac"]}");

  http.Response response = await http.post(
    Uri.parse(Endpoints.createOrderUrl),
    headers: header,
    body: body,
);


  print("body_request: $body");
  if (response.statusCode != 200) {
    return null;
  }

  var data = jsonDecode(response.body);
  print("data_response: $data}");

  return CreateOrderResponse.fromJson(data);
}
