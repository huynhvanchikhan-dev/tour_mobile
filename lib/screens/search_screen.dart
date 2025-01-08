import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tour_new_version/screens/post_screen.dart';
import 'package:tour_new_version/services/tours_api_service.dart';
import 'package:tour_new_version/services/destinations_api_service.dart';
import 'package:tour_new_version/models/tour_model.dart';
import 'package:tour_new_version/models/destination_model.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _departureDateController = TextEditingController();
  String? _selectedCategory;
  String? _selectedDestination;
  List<Map<String, dynamic>> categories = [];
  List<Destination> destinations = [];
  List<Tour> searchResults = [];
  String baseUrl = "http://54.66.21.87:8080";
  bool _isLoading = false;
  final _formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchDestinations();
  }

  Future<void> _fetchCategories() async {
    final apiService = ToursApiService(baseUrl: baseUrl);
    try {
      categories = await apiService.fetchCategoriesWithDetails();
      setState(() {});
    } catch (e) {
      _showErrorDialog('Lỗi', 'Không thể tải danh mục tour: $e');
    }
  }

  Future<void> _fetchDestinations() async {
    final apiService = DestinationsApiService(baseUrl: baseUrl);
    try {
      destinations = await apiService.fetchDestinations();
      setState(() {});
    } catch (e) {
      _showErrorDialog('Lỗi', 'Không thể tải danh sách điểm đến: $e');
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _departureDateController.text = formattedDate;
      });
    }
  }

  void _searchTours() async {
    setState(() {
      _isLoading = true;
    });

    final apiService = ToursApiService(baseUrl: baseUrl);
    try {
      final tours = await apiService.searchTours(
        destination: _selectedDestination,
        departureDate: _departureDateController.text.isNotEmpty
            ? _departureDateController.text
            : null,
        category: _selectedCategory,
      );

      setState(() {
        searchResults = tours;
        _isLoading = false;
      });

      if (searchResults.isEmpty) {
        _showErrorDialog('Thông báo', 'Không tìm thấy tour phù hợp');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Lỗi', 'Không thể tìm kiếm tour: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm tour')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Chọn điểm đến',
                border: OutlineInputBorder(),
              ),
              value: _selectedDestination,
              hint: Text('Chọn điểm đến'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDestination = newValue;
                });
              },
              items: destinations.map<DropdownMenuItem<String>>((destination) {
                return DropdownMenuItem<String>(
                  value: destination.name.toString(),
                  child: Text(destination.name),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _departureDateController,
              decoration: InputDecoration(
                labelText: 'Ngày khởi hành',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Chọn loại hình tour',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              hint: Text('Chọn loại hình tour'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((category) {
                return DropdownMenuItem<String>(
                  value: category['id'].toString(),
                  child: Text(category['name']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchTours,
              child: Text('Tìm kiếm'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: searchResults.isEmpty
                        ? Center(child: Text('Chưa có kết quả tìm kiếm'))
                        : ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final tour = searchResults[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostScreen(tourId: tour.id),
                                          ),
                                        );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          tour.images.isNotEmpty ? tour.images[0] : '',
                                          width: 120,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tour.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              tour.destination,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              _formatCurrency.format(tour.price),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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