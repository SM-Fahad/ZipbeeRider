import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class TopUpPaymentService {
  static Future<Map<String, dynamic>> addMoney({
    required double amount,
    required String currency,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse(ApiEndPoint.addMoney);

      final body = {
        'amount': amount,
        'currency': currency,
        'orderId': null,
        'payType': 'ONLINE_PAY',
        'type': 'ADD_MONEY',
      };

      debugPrint('➡️ TopUp POST body: $body to $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint('⬅️ TopUp Response Status: ${response.statusCode}');
      debugPrint('⬅️ TopUp Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'statusCode': response.statusCode,
          'success': false,
          'body': {'message': 'Empty response from server'},
        };
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final bool success = decoded['success'] == true || 
                             response.statusCode == 200 || 
                             response.statusCode == 201;
        return {
          'statusCode': response.statusCode,
          'success': success,
          'body': decoded,
        };
      } else {
        return {
          'statusCode': response.statusCode,
          'success': response.statusCode == 200 || response.statusCode == 201,
          'body': {'message': 'Unexpected response format'},
        };
      }
    } catch (e) {
      debugPrint('❌ TopUpPaymentService Error: $e');
      return {
        'statusCode': 500,
        'success': false,
        'body': {'message': 'Connection error: ${e.toString()}'},
      };
    }
  }
}