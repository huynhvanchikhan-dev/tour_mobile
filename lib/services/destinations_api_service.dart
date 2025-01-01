import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tour_new_version/models/destination_model.dart';

class DestinationsApiService {
  final String baseUrl;

  DestinationsApiService({required this.baseUrl});

  Future<List<Destination>> fetchDestinations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/tours/destinations'));

      if (response.statusCode == 202) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Destination.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load destinations');
      }
    } catch (e) {
      throw Exception('Error fetching destinations: $e');
    }
  }

  // Fetch single tour details
  Future<List<Destination>> fetchTourByDestination(String destinationId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/tours/destinations/${destinationId}/tours'));

      if (response.statusCode == 202) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Destination.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load destinations');
      }
    } catch (e) {
      throw Exception('Error fetching destinations: $e');
    }
  }
}
