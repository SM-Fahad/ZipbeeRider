import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  static String get chatHistory => ApiEndPoint.chatHistory;

  static Future<Map<String, dynamic>?> getChatHistoryData({
    required String receiverId,
    required String orderId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(chatHistory),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"otherUserId": receiverId, "orderId": orderId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data'] is Map<String, dynamic>) {
          return data['data'];
        }
        return {'messages': data['data']['messages'] ?? []};
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("❌ Rider getChatHistoryData error: $e");
      return null;
    }
  }

  static Future<List<dynamic>?> getChatHistory({
    required String receiverId,
    required String orderId,
  }) async {
    try {
      final data = await getChatHistoryData(
        receiverId: receiverId,
        orderId: orderId,
      );
      return data?['messages'] as List<dynamic>?;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> markAsRead(String conversationId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.chatMarkAsRead(conversationId);

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Rider markAsRead REST error: $e");
      return false;
    }
  }
}
