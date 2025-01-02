import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tour_new_version/models/auth_manager.dart';
import 'package:tour_new_version/screens/order_details_screen.dart';
import 'package:tour_new_version/services/booking_api_service.dart';

class BookedScreen extends StatefulWidget {
  const BookedScreen({Key? key}) : super(key: key);

  @override
  _BookedScreenState createState() => _BookedScreenState();
}

class _BookedScreenState extends State<BookedScreen> {
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo _bookingsFuture ngay từ đầu
    _bookingsFuture = _fetchBookings();
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() {
    final token = Provider.of<AuthManager>(context, listen: false).jwtToken ?? "";
    final bookingApiService = Provider.of<BookingApiService>(context, listen: false);
    
    return bookingApiService.getUserBookings(token);
  }

  Future<void> _refreshBookings() async {
    setState(() {
      _bookingsFuture = _fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn đặt tour của tôi'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _refreshBookings,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refreshBookings,
            child: bookings.isEmpty
                ? ListView(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text(
                            'Bạn chưa có đơn đặt tour nào',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(), // Quan trọng để RefreshIndicator hoạt động
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return InkWell(
                        onTap: () async {
                          // Chờ kết quả từ màn hình chi tiết và làm mới nếu có thay đổi
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(
                                bookingData: booking,
                              ),
                            ),
                          );

                          // Nếu có kết quả trả về (ví dụ như đã hủy tour), làm mới danh sách
                          if (result == true) {
                            _refreshBookings();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking['tourname'] ?? 'Tên tour',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Mã đơn: ${booking['id']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Trạng thái: ${booking['bookingStatus']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _getStatusColor(booking['bookingStatus']),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Tổng tiền: ${booking['totalPrice']}₫',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CREATED':
        return Colors.blue;
      case 'CANCELED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}