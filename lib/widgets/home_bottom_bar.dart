import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:tour_new_version/models/auth_manager.dart';
import 'package:tour_new_version/screens/favorite_screen.dart';
import 'package:tour_new_version/screens/login_screen.dart';
import 'package:tour_new_version/screens/profile_screen.dart';
import 'package:tour_new_version/screens/home_screen.dart';


class HomeBottomBar extends StatefulWidget {
  final int initialIndex;
  const HomeBottomBar({Key? key, this.initialIndex = 2}) : super(key: key);

  @override
  State<HomeBottomBar> createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  late int _currentIndex;

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const ProfileScreen(),
    const FavoriteScreen(),
    const HomeScreen(),
    // Thêm các màn hình khác nếu cần
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigateToScreen(int index, BuildContext context) {
    final auth = context.read<AuthManager>();

    // Xử lý điều hướng đặc biệt cho icon person
    if (index == 0) {
      if (!auth.isLoggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Color _getAppBarColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue; // Màu cho ProfileScreen
      case 1:
        return Colors.red; // Màu cho FavoriteScreen
      case 2:
        return Colors.green; // Màu cho HomeScreen
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: _getAppBarColor(_currentIndex),
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) => _navigateToScreen(index, context),
        items: [
          Icon(
            Icons.person_outline, 
            color: _currentIndex == 0 ? Colors.white : Colors.white70,
          ),
          Icon(
            Icons.favorite_outline, 
            color: _currentIndex == 1 ? Colors.white : Colors.white70,
          ),
          Icon(
            Icons.home, 
            color: _currentIndex == 2 ? Colors.white : Colors.white70,
          ),
          // Thêm các icon khác nếu cần
        ],
      ),
    );
  }
}