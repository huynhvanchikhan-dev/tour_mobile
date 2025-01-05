import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PromotionNotificationService {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://54.252.193.168:8080/ws'),
  );

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PromotionNotificationService() {
    _checkAndRequestNotificationPermissions();

    // Cấu hình Flutter Local Notifications
    const androidInitializationSettings = AndroidInitializationSettings('app_icon');
    const iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    _notificationsPlugin.initialize(initializationSettings);

    // Lắng nghe thông báo từ WebSocket
    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      _showNotification(data['conditions'], data['code']);
    });
  }

  Future<void> _checkAndRequestNotificationPermissions() async {
    // Yêu cầu quyền thông báo trên cả Android và iOS
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _showNotification(String title, String body) async {
    if (await Permission.notification.isGranted) {
      const androidDetails = AndroidNotificationDetails(
        'promotion_channel',
        'Promotions',
        channelDescription: 'Channel for promotion notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
    } else {
      print("Notification permission not granted.");
    }
  }

  void dispose() {
    _channel.sink.close();
  }
}
