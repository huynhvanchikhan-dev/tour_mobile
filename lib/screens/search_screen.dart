import 'package:flutter/material.dart';
import 'package:tour_new_version/services/tours_api_service.dart';
import 'package:tour_new_version/models/tour_model.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _departureDateController = TextEditingController();
  String? _selectedCategory;
  List<String> categories = [];
  List<Tour> searchResults = [];
  String baseUrl = "http://54.252.193.168:8080";

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final apiService = ToursApiService(baseUrl: baseUrl);
    try {
      categories = await apiService.fetchCategories();
      setState(() {});
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _searchTours() async {
    final apiService = ToursApiService(baseUrl: baseUrl);
    try {
      final tours = await apiService.searchTours(
        destination: _destinationController.text,
        departureDate: _departureDateController.text.isNotEmpty
            ? _departureDateController.text // Giữ nguyên chuỗi
            : null,
        category: _selectedCategory,
      );
      setState(() {
        searchResults = tours;
      });
    } catch (e) {
      print('Error searching tours: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm tour')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(labelText: 'Điểm đến'),
            ),
            TextField(
              controller: _departureDateController,
              decoration: InputDecoration(labelText: 'Ngày khởi hành (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
            ),
            DropdownButton<String>(
              hint: Text('Chọn loại hình tour'),
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
 child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchTours,
              child: Text('Tìm kiếm'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final tour = searchResults[index];
                  return ListTile(
                    title: Text(tour.title),
                    subtitle: Text(tour.description),
                    onTap: () {
                      // Xử lý khi người dùng nhấn vào tour
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}