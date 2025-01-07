import 'dart:convert';
import 'package:tour_new_version/models/tour_model.dart';
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

  // Fetch categories
  Future<List<String>> fetchCategories() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/tours/categories'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<String>.from(jsonData.map((category) => category['name']));
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Search tours
  Future<List<Tour>> searchTours({
    String? destination,
    String? departureDate, // Đảm bảo đây là String?
    String? category,
  }) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/api/v1/tours?destination=$destination&departureDate=$departureDate&category=$category'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> content = jsonData['content'] ?? [];
      return content.map((tour) => Tour.fromJson(tour)).toList();
    } else {
      throw Exception('Failed to search tours');
    }
  }
}
