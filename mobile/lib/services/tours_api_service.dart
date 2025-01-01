import 'dart:convert';
import 'package:mobile/models/tour_model.dart';
import 'package:http/http.dart' as http;

class ToursApiService {
  final String baseUrl;

  ToursApiService({required this.baseUrl});

  // Fetch list of tours
  Future<List<Tour>> fetchTours() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/tours'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> content = jsonData['content'] ?? [];
      return content.map((tour) => Tour.fromJson(tour)).toList();
    } else {
      throw Exception('Failed to load tours');
    }
  }

  // Fetch single tour details
  Future<Tour> fetchTourDetails(String tourId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/tours/$tourId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Tour.fromJson(data);
    } else {
      throw Exception('Failed to load tour details');
    }
  }
}
