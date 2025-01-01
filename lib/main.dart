import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tour_new_version/models/auth_manager.dart';
import 'package:tour_new_version/screens/welcome_screen.dart';
import 'package:tour_new_version/services/booking_api_service.dart';
import 'package:tour_new_version/services/user_api_service.dart';

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

// import 'package:flutter/material.dart';
// import 'package:tour_new_version/testzalopay/dashboard.dart';


// void main() => runApp(App());

// class App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Test",
//       theme: ThemeData(
//   brightness: Brightness.light,
//   textTheme: TextTheme(
//     bodyMedium: TextStyle(color: Colors.blue, fontSize: 18.0),
//     headlineLarge: TextStyle(color: Colors.white),
// ),
//   fontFamily: 'Josefin Sans',
//   primaryColor: Colors.blue,
//   // scaffoldBackgroundColor: AppColor.primaryColor,
// ),
//       home: Dashboard(title: "Test", version: "v2"),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }