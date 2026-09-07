import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OrderDetailsService {
  Future<OrderModel> fetchOrderDetail(int orderId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('${ApiEndPoint.baseUrl}/order/$orderId');
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      debugPrint('Order details response status: ${response.statusCode}');
      debugPrint('Order details response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : <String, dynamic>{};
        return OrderModel.fromJson(data);
      }

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode == 404) {
        throw Exception('Order not found.');
      }

      throw Exception('Failed to load order details: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching order details: $e');
    }
  }
}
