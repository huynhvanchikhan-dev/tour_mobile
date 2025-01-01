import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/auth_manager.dart';
import 'package:mobile/screens/welcome_screen.dart';
import 'package:mobile/services/booking_api_service.dart';
import 'package:mobile/services/user_api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<BookingApiService>(create: (_) => BookingApiService(baseUrl: 'http://54.252.193.168:8080')),
        ChangeNotifierProvider(create: (_) => AuthManager()),
        Provider<UserApiService>(create: (_) => UserApiService(baseUrl: 'http://54.252.193.168:8080')),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget{

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState(){
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFEDF2F6),
      ),
      home: WelcomeScreen(),
    );
  }
}

