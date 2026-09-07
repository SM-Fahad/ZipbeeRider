import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('Permission granted');
  }
}

Future<String?> getFcmToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM Token: $token");
  return token;
}

Future<void> sendCurrentFcmTokenToBackend() async {
  try {
    final fcmToken = await getFcmToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      debugPrint("FCM Token not available");
      return;
    }

    await sendFcmTokenToBackend(fcmToken);
  } catch (e) {
    debugPrint("Error sending FCM token to backend: $e");
  }
}

Future<void> sendFcmTokenToBackend(String token) async {
  final userToken = await SharedPreferencesHelper.getAccessToken();
  if (userToken == null || userToken.isEmpty) {
    debugPrint("Access token not available for FCM token update");
    return;
  }

  try {
    debugPrint("FCM Token final token: $token");
    final response = await http.patch(
      Uri.parse(ApiEndPoint.notificationFcmToken),
      headers: {
        "accept": "*/*",
        "Authorization": "Bearer $userToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"fcmToken": token}),
    );

    debugPrint("FCM Token Response: ${response.statusCode} ${response.body}");
  } catch (e) {
    debugPrint("FCM Token update failed: $e");
  }
}

void listenTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    sendFcmTokenToBackend(newToken);
  });
}
