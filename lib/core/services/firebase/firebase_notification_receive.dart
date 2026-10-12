import 'dart:convert';

import 'package:ZipBee_Driver/features/order_details/screen/order_details_screen.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/screen/dispute_details_screen.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/screen/dispute_screen.dart';
import 'package:ZipBee_Driver/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FirebaseNotificationReceive {
  static const String _androidChannelId = 'default_channel';
  static const String _androidChannelName = 'Default Notifications';
  static const String _androidChannelDescription =
      'This channel is used for important notifications.';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _handleNotificationPayload(response.payload!);
        }
      },
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.max,
      ),
    );
  }

  static void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      debugPrint('Message body: ${message.notification?.body}');

      _showLocalNotification(message);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Background message: ${message.messageId}");
    debugPrint("Background message title: ${message.notification?.title}");

    await initializeLocalNotifications();
    await _showLocalNotification(message);
  }

  static void setupBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // Format any unrounded decimals in the body before presenting
    String body = message.notification?.body ?? 'You have a new message';
    body = body.replaceAllMapped(
      RegExp(r'(\d+\.\d{3,})'),
      (match) {
        final val = double.tryParse(match.group(1) ?? '');
        return val != null ? val.toStringAsFixed(2) : match.group(0)!;
      },
    );

    await _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  static void _handleNotificationPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        handleNotificationNavigation(decoded);
      } else if (decoded is Map) {
        handleNotificationNavigation(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      debugPrint("Error parsing notification payload: $e");
    }
  }

  static void handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint("handleNotificationNavigation with data: $data");
    final redirectType = data['redirectType']?.toString().toUpperCase();
    final screen = data['screen']?.toString();
    final type = data['type']?.toString().toUpperCase();

    if (redirectType == 'DISPUTE_DETAILS' ||
        screen == 'DisputeDetails' ||
        type == 'DISPUTE_RESOLVED') {
      final rawDisputeId = data['disputeId'] ?? data['orderDisputeId'];
      final rawOrderId = data['orderId'];

      final disputeId = rawDisputeId is int
          ? rawDisputeId
          : int.tryParse(rawDisputeId?.toString() ?? '');
      final orderId = rawOrderId is int
          ? rawOrderId
          : int.tryParse(rawOrderId?.toString() ?? '');

      if (disputeId != null || orderId != null) {
        Get.to(() => DisputeDetailsScreen(
              disputeId: disputeId,
              orderId: orderId,
            ));
      } else {
        Get.to(() => const DisputeScreen());
      }
      return;
    }

    if (type == 'ORDER_UPDATE') {
      final rawOrderId = data['orderId'];
      final orderId = rawOrderId is int
          ? rawOrderId
          : int.tryParse(rawOrderId?.toString() ?? '');
      if (orderId != null) {
        Get.to(() => OrderDetailsScreen(), arguments: orderId);
      }
      return;
    }
  }

  static void setupMessageOpenedAppListeners() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenedApp triggered: ${message.data}");
      handleNotificationNavigation(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("getInitialMessage triggered: ${message.data}");
        handleNotificationNavigation(message.data);
      }
    });
  }
}
