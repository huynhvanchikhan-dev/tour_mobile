import 'package:flutter/material.dart';
import 'package:tour_new_version/models/tour_model.dart';
import 'package:intl/intl.dart';
import 'package:tour_new_version/screens/booking_screen.dart';
import 'package:tour_new_version/screens/full_screen_gallery.dart';

class PostBottomBar extends StatelessWidget {
  final Tour tour;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  PostBottomBar({required this.tour, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: ListView(
        children: [
          // Title & Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  tour.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 25,
                  ),
                  Text(
                    "4.5", // Có thể thay bằng dữ liệu đánh giá nếu có
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          // Price
          Text(
            "Giá: ${formatCurrency.format(tour.price)}",
            style: TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 15),
          // Description
          Text(
            "Mô tả",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            tour.description,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 20),
          // Itinerary
          Text(
            "Lịch trình chuyến đi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tour.itinerary.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tour.itinerary[index],
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // Images
          Row(
            children: tour.images.take(3).map((imageUrl) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenGallery(images: tour.images),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 90,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 15),
          // Booking Options
          Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    Icons.reviews_rounded,
                    size: 30,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(tour: tour),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Màu nền nút
                      foregroundColor: Colors.white, // Màu chữ
                      padding: EdgeInsets.symmetric(
                          vertical: 18, horizontal: 30), // Cân đối padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bo góc nút
                      ),
                      elevation: 4, // Tăng hiệu ứng đổ bóng
                    ),
                    child: Text(
                      "Đặt ngay",
                      style: TextStyle(
                        fontSize: 18, // Cỡ chữ phù hợp hơn
                        fontWeight: FontWeight.bold, // Chữ đậm để nổi bật hơn
                        letterSpacing: 1.0, // Tăng khoảng cách chữ cho cân đối
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
