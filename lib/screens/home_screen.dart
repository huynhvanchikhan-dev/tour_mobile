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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DestinationsApiService _destinationsApiService =
      DestinationsApiService(baseUrl: 'http://${ApiBaseConfig.IP}:8080');
  final ToursApiService _toursApiService =
      ToursApiService(baseUrl: 'http://${ApiBaseConfig.IP}:8080');
  final _formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  // Biến lưu trữ tương lai data (Future) để dùng trong FutureBuilder
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm fetch khi khởi tạo
    _dataFuture = _fetchData();
  }

  // Hàm fetch data (call API) - fetch cả destinations và tours
  Future<List<dynamic>> _fetchData() async {
    try {
      final destinationsFuture = _destinationsApiService.fetchDestinations();
      final toursFuture = _toursApiService.fetchTours();
      // Chờ cả hai future cùng hoàn thành
      
      return await Future.wait([destinationsFuture, toursFuture]);
    } catch (e) {
      // Bắt lỗi tại đây (mất mạng, server error, v.v.)
      rethrow;
    }
  }

  // Hàm được gọi khi người dùng kéo xuống để refresh
  Future<void> _onRefresh() async {
    setState(() {
      // Gọi lại _fetchData để FutureBuilder bên dưới cập nhật
      _dataFuture = _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0),
        child: SafeArea(child: HomeAppBar()),
      ),
      body: SafeArea(
        // Thêm RefreshIndicator bọc quanh FutureBuilder
        child: RefreshIndicator(
          onRefresh: _onRefresh, 
          child: FutureBuilder<List<dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              // Đang chờ dữ liệu
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } 
              // Nếu có lỗi
              else if (snapshot.hasError) {
                String error = snapshot.error.toString();
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _onRefresh, 
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              } 
              // Không có dữ liệu
              else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              // Nếu thành công, lấy data
              final destinations = snapshot.data![0] as List<Destination>;
              final tours = snapshot.data![1] as List<Tour>;

              // Lọc tour đã được duyệt
              final approvedTours =
                  tours.where((tour) => tour.status == "APPROVED").toList();
              final featuredTours =
                  approvedTours.where((tour) => tour.featured).toList();
              final allTours = approvedTours;

              return Column(
                children: [
                  // Danh sách các địa điểm (Destinations)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: destinations.length,
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        return InkWell(
                          onTap: () {
                            // Xử lý khi nhấn vào destination
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FillterSoftScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.all(10),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                  colors: [Colors.black54, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: Text(
                                destination.name,
                                style: const TextStyle(
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
                  const SizedBox(height: 20),

                  // Danh sách Tour kèm TabBar
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
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
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                            // Ảnh Tour
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
                                            const SizedBox(width: 15),
                                            // Thông tin Tour
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tour.title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    _formatCurrency
                                                        .format(tour.price),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                            // Ảnh Tour
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
                                            const SizedBox(width: 15),
                                            // Thông tin Tour
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tour.title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    _formatCurrency
                                                        .format(tour.price),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
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
      ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}
