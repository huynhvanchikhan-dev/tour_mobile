import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tour_new_version/models/booking_request.dart';
import 'package:tour_new_version/models/payment_request.dart';

class BookingApiService {
  final String baseUrl;

  BookingApiService({required this.baseUrl});

  Future<Map<String, dynamic>> createBooking(
    BookingRequest bookingRequest, String token) async {
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
      return jsonDecode(response
          .body); // Assuming the backend returns the bookingId within the response body
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
      return data['orderurl']; // Assuming 'orderurl' is part of the response
    } else {
      throw Exception('Failed to initiate payment: ${response.body}');
    }
  }

  Future<void> cancelBooking(String bookingId, String token) async {
    final url = Uri.parse('$baseUrl/api/v2/booking/cancel/$bookingId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to cancel booking');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String token) async {
  final url = Uri.parse('$baseUrl/api/v2/booking/users');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    // Giải mã JSON và trả về danh sách booking
    List<dynamic> bookingsJson = jsonDecode(response.body);
    return bookingsJson.map((booking) => booking as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to fetch bookings: ${response.body}');
  }
}
}
