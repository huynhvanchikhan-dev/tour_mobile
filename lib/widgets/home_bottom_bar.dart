import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_booking/models/auth_manager.dart';
import 'package:tour_booking/screens/login_screen.dart';
import 'package:tour_booking/screens/profile_screen.dart';


class HomeBottomBar extends StatefulWidget {
  const HomeBottomBar({super.key});

  @override
  State<HomeBottomBar> createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthManager>();

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        // Icon "person" = 0
        if (index == 0) {
          if (!auth.isLoggedIn) {
            // Chưa đăng nhập => sang LoginScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          } else {
            // Đã đăng nhập => sang ProfileScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Person'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Favorite'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        // ...
      ],
    );
  }
}
