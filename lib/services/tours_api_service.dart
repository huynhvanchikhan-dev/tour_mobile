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
  // Thêm phương thức fetchCategoriesWithDetails
  Future<List<Map<String, dynamic>>> fetchCategoriesWithDetails() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/tours/categories'));

    if (response.statusCode == 202) {
      final jsonData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Search tours
  Future<List<Tour>> searchTours({
    String? destination,
    String? departureDate,
    String? category,
  }) async {
    // Construct the query parameters
    final queryParameters = {
      if (destination != null && destination.isNotEmpty)
        'destination': destination,
      if (departureDate != null && departureDate.isNotEmpty)
        'departureDate': departureDate,
      if (category != null && category.isNotEmpty) 'category': category,
    };

    // Create the URL with query parameters
    final uri = Uri.parse('$baseUrl/api/v1/tours')
        .replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> content = jsonData['content'] ?? [];
      return content.map((tour) => Tour.fromJson(tour)).toList();
    } else {
      throw Exception('Failed to search tours: ${response.body}');
    }
  }
}
