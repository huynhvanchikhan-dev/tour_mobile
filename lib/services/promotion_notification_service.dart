import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class PromotionNotificationService {
  static final PromotionNotificationService _instance =
      PromotionNotificationService._internal();
  factory PromotionNotificationService() => _instance;

  PromotionNotificationService._internal() {
    _initializeNotifications();
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StompClient? _stompClient;

  // WebSocket configuration
  static const String _wsUrl = 'ws://54.252.193.168:8080/ws';
  static const int _reconnectDelay = 5; // seconds
  static const int _connectionTimeout = 10; // seconds

  // Lưu trữ các khuyến mãi
  final List<Map<String, dynamic>> _promotions = [];

  // Getter để truy xuất danh sách khuyến mãi
  List<Map<String, dynamic>> get promotions => List.unmodifiable(_promotions);

  Future<void> _initializeNotifications() async {
    try {
      await _checkAndRequestNotificationPermissions();

      const androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosInitializationSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Khởi tạo kết nối WebSocket
      _initializeWebSocket();
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  void _initializeWebSocket() {
    _stompClient = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: _onWebSocketConnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        onDisconnect: _onDisconnect,
        reconnectDelay: Duration(seconds: _reconnectDelay),
        connectionTimeout: Duration(seconds: _connectionTimeout),
      ),
    );

    _stompClient?.activate();
  }

  void _onWebSocketConnect(StompFrame? frame) {
    debugPrint('WebSocket connected successfully');
    _subscribeToPromotionTopic();
  }

  void _subscribeToPromotionTopic() {
    _stompClient?.subscribe(
      destination: '/topic/promotions',
      callback: (StompFrame frame) {
        debugPrint('Received promotion: ${frame.body}');
        _handlePromotionMessage(frame.body);
      },
    );
  }

  void _handlePromotionMessage(String? body) {
    if (body == null) return;

    try {
      final promotionData = json.decode(body);

      // Lưu khuyến mãi vào danh sách
      _promotions.add(promotionData);

      // Hiển thị thông báo
      _showPromotionNotification(promotionData);

      // Lưu khuyến mãi vào SharedPreferences
      _savePromotionLocally(promotionData);
    } catch (e) {
      debugPrint('Error parsing promotion: $e');
    }
  }

  Future<void> _savePromotionLocally(Map<String, dynamic> promotion) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy danh sách khuyến mãi đã lưu
    List<String> savedPromotions = prefs.getStringList('promotions') ?? [];

    // Thêm khuyến mãi mới
    savedPromotions.add(json.encode(promotion));

    // Lưu danh sách khuyến mãi
    await prefs.setStringList('promotions', savedPromotions);
  }

  Future<List<Map<String, dynamic>>> getSavedPromotions() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> savedPromotions = prefs.getStringList('promotions') ?? [];

    return savedPromotions
        .map((p) => Map<String, dynamic>.from(json.decode(p)))
        .toList();
  }

  Future<void> _showPromotionNotification(
      Map<String, dynamic> promotionData) async {
    final androidDetails = AndroidNotificationDetails(
      'promotion_channel',
      'Promotions',
      channelDescription: 'Promotional notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        'New Promotion!',
        _formatPromotionMessage(promotionData),
        notificationDetails,
        payload: json.encode(promotionData),
      );
    } catch (e) {
      debugPrint('Notification display error: $e');
    }
  }

  String _formatPromotionMessage(Map<String, dynamic> data) {
    return 'Use code ${data['code'] ?? 'PROMO'} '
        'for ${data['discountValue'] ?? '0'}% off';
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final promotionData = json.decode(response.payload!);
        // Xử lý khi người dùng nhấn vào thông báo
        debugPrint('Notification tapped: $promotionData');
        // Có thể thêm logic chuyển đến trang chi tiết khuyến mãi
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _checkAndRequestNotificationPermissions() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onStompError(StompFrame frame) {
    debugPrint('STOMP Error: ${frame.body}');
    _handleConnectionError();
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('WebSocket Error: $error');
    _handleConnectionError();
  }

  void _onDisconnect(StompFrame? frame) {
    debugPrint('WebSocket Disconnected');
    _handleConnectionError();
  }

  void _handleConnectionError() {
    Future.delayed(Duration(seconds: _reconnectDelay), () {
      _initializeWebSocket();
    });
  }

  void dispose() {
    _stompClient?.deactivate();
  }
}
