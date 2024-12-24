import 'package:flutter/material.dart';
import 'package:tour_booking/models/destination_model.dart';
import 'package:tour_booking/models/tour_model.dart';
import 'package:tour_booking/screens/fillter_soft_screen.dart';
import 'package:tour_booking/screens/post_screen.dart';
import 'package:tour_booking/services/destinations_api_service.dart';
import 'package:tour_booking/services/tours_api_service.dart';
import 'package:tour_booking/utils/api_base_config.dart';
import 'package:tour_booking/widgets/home_app_bar.dart';
import 'package:tour_booking/widgets/home_bottom_bar.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final DestinationsApiService destinationsApiService =
      DestinationsApiService(baseUrl: 'http://${ApiBaseConfig.IP}:8080');
  final ToursApiService toursApiService =
      ToursApiService(baseUrl: 'http://${ApiBaseConfig.IP}:8080');
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: SafeArea(child: HomeAppBar()),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: Future.wait([
            destinationsApiService.fetchDestinations(),
            toursApiService.fetchTours()
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            }

            final destinations = snapshot.data![0] as List<Destination>;
            final tours = snapshot.data![1] as List<Tour>;

            // Filter only approved tours
            final approvedTours =
                tours.where((tour) => tour.status == "APPROVED").toList();
            final featuredTours =
                approvedTours.where((tour) => tour.featured).toList();
            final allTours = approvedTours;

            return Column(
              children: [
                // Destinations List
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final destination = destinations[index];
                      return InkWell(
                        onTap: () {
                          // Handle destination click
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FillterSoftScreen()));
                        },
                        child: Container(
                          width: 160,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(destination.url),
                              fit: BoxFit.cover,
                              opacity: 0.8,
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.black54, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Text(
                              destination.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),

                // Tours List with TabBar
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Colors.black,
                          indicatorColor: Colors.red,
                          tabs: [
                            Tab(text: "Featured Tours"),
                            Tab(text: "All Tours"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Featured Tours
                              ListView.builder(
                                itemCount: featuredTours.length,
                                itemBuilder: (context, index) {
                                  final tour = featuredTours[index];
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
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20), // Adjust margins
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Tour Image
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              tour.images.isNotEmpty
                                                  ? tour.images[0]
                                                  : '',
                                              width: 120,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          // Tour Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tour.title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  tour.destination,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  formatCurrency
                                                      .format(tour.price),
                                                  style: TextStyle(
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

                              // All Tours
                              ListView.builder(
                                itemCount: allTours.length,
                                itemBuilder: (context, index) {
                                  final tour = allTours[index];
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
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20), // Adjust margins
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Tour Image
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              tour.images.isNotEmpty
                                                  ? tour.images[0]
                                                  : '',
                                              width: 120,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          // Tour Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tour.title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  tour.destination,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  formatCurrency
                                                      .format(tour.price),
                                                  style: TextStyle(
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}
