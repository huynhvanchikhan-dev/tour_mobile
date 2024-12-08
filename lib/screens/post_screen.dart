import 'package:flutter/material.dart';
import 'package:tour_booking/models/tour_model.dart';
import 'package:tour_booking/services/tours_api_service.dart';
import 'package:tour_booking/widgets/post_app_bar.dart';
import 'package:tour_booking/widgets/post_bottom_bar.dart';

class PostScreen extends StatelessWidget {
  final String tourId;
  final ToursApiService toursApiService =
      ToursApiService(baseUrl: 'http://192.168.1.5:8080');

  PostScreen({required this.tourId, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tour>(
      future: toursApiService.fetchTourDetails(tourId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(90),
              child: SafeArea(child: PostAppBar()),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(90),
              child: SafeArea(child: PostAppBar()),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(90),
              child: SafeArea(child: PostAppBar()),
            ),
            body: Center(child: Text('Tour not found')),
          );
        }

        final tour = snapshot.data!;
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                tour.images.isNotEmpty ? tour.images[0] : "https://via.placeholder.com/600x400",
              ),
              fit: BoxFit.cover,
              opacity: 0.7,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(90),
              child: SafeArea(child: PostAppBar()),
            ),
            bottomNavigationBar: PostBottomBar(tour: tour),
          ),
        );
      },
    );
  }
}
