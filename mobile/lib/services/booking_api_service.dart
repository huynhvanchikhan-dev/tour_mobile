import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tour_new_version/models/booking_request.dart';
import 'package:tour_new_version/models/payment_request.dart';

class BookingApiService {
  final String baseUrl;

  BookingApiService({required this.baseUrl});

  Future<Map<String, dynamic>> createBooking(BookingRequest bookingRequest, String token) async {
    print("Booking request: " + bookingRequest.fullname);
    final url = Uri.parse('$baseUrl/api/v2/booking');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bookingRequest.toJson()),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body); // Assuming the backend returns the bookingId within the response body
    } else {
      throw Exception('Failed to create booking: ${response.body}');
    }
  }

  Future<String> initiatePayment(PaymentRequest request, String token) async {
  final url = Uri.parse('$baseUrl/api/v2/payments/create-order');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(request.toJson()), // Correctly pass the map
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['orderurl'];  // Assuming 'orderurl' is part of the response
  } else {
    throw Exception('Failed to initiate payment: ${response.body}');
  }
}

}
