import 'package:flutter/material.dart';
import 'package:tour_booking/models/tour_model.dart';
import 'package:tour_booking/widgets/fillter_app_bar.dart';

class FillterSoftScreen extends StatelessWidget {
  // final String tourId;

  // const FillterSoftScreen({super.key, required this.tourId});
  const FillterSoftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: SafeArea(child: FillterAppBar()),
      ),
    );
  }
}