import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tour_new_version/models/auth_manager.dart';
import 'package:tour_new_version/screens/home_screen.dart';
import 'package:tour_new_version/services/booking_api_service.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const OrderDetailsScreen({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  Future<void> _handleCancelTour(BuildContext context) async {
    try {
      // Get token from AuthManager
      final token =
          Provider.of<AuthManager>(context, listen: false).jwtToken ?? "";
      final bookingApiService =
          Provider.of<BookingApiService>(context, listen: false);

      // Show confirmation dialog
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận hủy tour'),
          content: const Text('Bạn có chắc chắn muốn hủy tour này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Không',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Có',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      // Trong phương thức _handleCancelTour của OrderDetailsScreen
      if (shouldCancel == true) {
        await bookingApiService.cancelBooking(bookingData['id'], token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hủy tour thành công')),
        );
        Navigator.pop(context, true); // ```dart
      } else {
        Navigator.pop(context, false); // Không có thay đổi
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi hủy tour: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Order Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Thông tin đơn hàng",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Order Details Form Fields
                    TextFormField(
                      initialValue: bookingData['id']?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: "Mã đơn hàng",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue:
                          bookingData['bookingStatus']?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: "Trạng thái",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue:
                          bookingData['paymentMethod']?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: "Phương thức thanh toán",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue:
                          '${bookingData['totalPrice']?.toString() ?? ''}₫',
                      decoration: InputDecoration(
                        labelText: "Tổng tiền",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: bookingData['numPeople']?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: "Số khách",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue:
                          bookingData['bookingDate']?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: "Ngày đặt",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cancel Button
            if (bookingData['bookingStatus'] == 'CREATED')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleCancelTour(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Hủy tour',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Khoảng cách giữa hai nút
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Thêm chức năng cho nút mới ở đây
                        // Ví dụ: in hóa đơn, chia sẻ thông tin đặt tour, v.v.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xff4DA1A9), // Màu như yêu cầu
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Chi tiết',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (bookingData['bookingStatus'] == 'CANCELED')
              ElevatedButton(
                onPressed: () {
                  // Quay về trang chủ
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4DA1A9),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Trở về trang chủ',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
