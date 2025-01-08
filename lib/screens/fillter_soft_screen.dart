import 'package:flutter/material.dart';
import 'package:tour_new_version/screens/post_screen.dart';
import 'package:tour_new_version/services/destinations_api_service.dart';
import 'package:tour_new_version/models/tour_model.dart';
import 'package:tour_new_version/utils/api_base_config.dart';
import 'package:intl/intl.dart';

class FillterSoftScreen extends StatefulWidget {
  final String destinationId;

  const FillterSoftScreen({Key? key, required this.destinationId})
      : super(key: key);

  @override
  _FillterSoftScreenState createState() => _FillterSoftScreenState();
}

class _FillterSoftScreenState extends State<FillterSoftScreen> {
  final DestinationsApiService _destinationsApiService =
      DestinationsApiService(baseUrl: 'http://54.66.21.87:8080');
  late Future<List<Tour>> _toursFuture;
  final _formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    initState();
    _toursFuture = _fetchToursByDestination();
  }

  Future<List<Tour>> _fetchToursByDestination() async {
    try {
      return await _destinationsApiService
          .fetchTourByDestination(widget.destinationId);
    } catch (e) {
      throw Exception('Error fetching tours: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tours'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Tour>>(
        future: _toursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tours found for this destination.'));
          }

          final tours = snapshot.data!;

          return ListView.builder(
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostScreen(tourId: tour.id),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
          );
        },
      ),
    );
  }
}
