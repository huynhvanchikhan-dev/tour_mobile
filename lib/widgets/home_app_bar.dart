import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tour_booking/models/auth_manager.dart';
import 'package:tour_booking/screens/login_screen.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String? _locationName; // Biến lưu tên địa điểm hiện tại (City, Country, v.v.)
  bool _isFetchingLocation =
      false; // Cờ để hiển thị trạng thái đang lấy location

  @override
  void initState() {
    super.initState();
    _fetchLocationIfLoggedIn();
  }

  /// Gọi hàm lấy vị trí nếu đã đăng nhập
  Future<void> _fetchLocationIfLoggedIn() async {
    final auth = context.read<AuthManager>();
    if (auth.isLoggedIn) {
      await _determinePositionAndConvert();
    }
  }

  /// Lấy vị trí (lat, lon), sau đó chuyển sang địa chỉ
  Future<void> _determinePositionAndConvert() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      // Hỏi quyền truy cập vị trí
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Nếu người dùng tắt GPS => thông báo
        // Hoặc bạn có thể yêu cầu họ bật
        setState(() {
          _locationName = "GPS is off";
          _isFetchingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationName = "Location permissions are denied";
            _isFetchingLocation = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Quyền bị từ chối vĩnh viễn
        setState(() {
          _locationName = "Location permissions are permanently denied";
          _isFetchingLocation = false;
        });
        return;
      }

      // Lúc này đã có quyền => lấy vị trí
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Từ lat, lon => tìm địa chỉ (thành phố, quốc gia, ...)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Tùy ý ghép trường: place.administrativeArea, place.country, v.v.
        final city = place.locality; // hoặc administrativeArea
        final country = place.country;
        setState(() {
          _locationName = "$city, $country";
        });
      } else {
        setState(() {
          _locationName = "Unknown location";
        });
      }
    } catch (e) {
      setState(() {
        _locationName = "Error: $e";
      });
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthManager>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon menu
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6)
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.sort_rounded, size: 28),
            ),
          ),

          // Nếu đã đăng nhập => hiển thị vị trí hiện tại
          // Nếu chưa => hiển thị nút Đăng nhập / Đăng ký
          auth.isLoggedIn
              ? Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFF67959)),
                    const SizedBox(width: 5),
                    // Nếu đang lấy vị trí => hiển thị "Đang xác định..."
                    // Nếu lấy xong => hiển thị _locationName
                    _isFetchingLocation
                        ? const Text(
                            "Đang xác định...",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        : Text(
                            _locationName ?? "Không thể xác định",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                  ],
                )
              : Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // chuyển sang màn hình login
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Đăng nhập"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // chuyển sang màn hình đăng ký
                      },
                      child: const Text("Đăng ký"),
                    ),
                  ],
                ),

          // Icon search
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6)
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.search, size: 28),
            ),
          )
        ],
      ),
    );
  }
}
