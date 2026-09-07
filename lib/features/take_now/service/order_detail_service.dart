import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/order_detail_response.dart';

class OrderDetailService {
  final baseUrl = '${ApiEndPoint.baseUrl}';

  Future<OrderDetailResponse> fetchOrderDetail(int orderId) async {
    try {
      // Get the access token from shared preferences
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/order/$orderId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return OrderDetailResponse.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found.');
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order details: $e');
    }
  }

  /// Accept order for driver/rider competition
  Future<Map<String, dynamic>> acceptOrderCompetition(int orderId) async {
    try {
      // Get the access token from shared preferences
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/order/driver/compitition/$orderId');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Accept Order Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found.');
      } else {
        throw Exception('Failed to accept order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error accepting order: $e');
    }
  }
}
