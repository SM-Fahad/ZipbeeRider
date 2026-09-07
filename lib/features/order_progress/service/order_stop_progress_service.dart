import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OrderStopProgressService {
  final baseUrl = ApiEndPoint.baseUrl;

  Future<String> _getToken() async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found. Please login first.');
    }
    return token;
  }

  Future<Map<String, dynamic>> updateStopProgress({
    required int stopId,
    required String step,
  }) async {
    try {
      final token = await _getToken();

      final url = Uri.parse('$baseUrl/order/stops/$stopId/progress');
      final payload = {'step': step};

      final response = await http
          .patch(
            url,
            headers: {
              'accept': '*/*',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      debugPrint('Stop progress response status: ${response.statusCode}');
      debugPrint('Stop progress response body: ${response.body}');

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (json['success'] == true) {
          return Map<String, dynamic>.from(json);
        }
        throw Exception(json['message'] ?? 'Failed to update stop progress');
      }

      throw Exception(json['message'] ?? 'Failed to update stop progress');
    } catch (e) {
      debugPrint('Error updating stop progress: $e');
      throw Exception('Error updating stop progress: $e');
    }
  }

  Future<Map<String, dynamic>> skipStop({required int stopId}) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/order/stops/$stopId/skiped');

      final response = await http
          .patch(
            url,
            headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      debugPrint('Skip stop response status: ${response.statusCode}');
      debugPrint('Skip stop response body: ${response.body}');

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (json['success'] == true) {
          return Map<String, dynamic>.from(json);
        }
        throw Exception(json['message'] ?? 'Failed to skip stop');
      }

      throw Exception(json['message'] ?? 'Failed to skip stop');
    } catch (e) {
      debugPrint('Error skipping stop: $e');
      throw Exception('Error skipping stop: $e');
    }
  }

  Future<Map<String, dynamic>> failStop({
    required int stopId,
    required String reason,
  }) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/order/stops/$stopId/fail');

      final response = await http
          .post(
            url,
            headers: {
              'accept': '*/*',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'reason': reason}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      debugPrint('Fail stop response status: ${response.statusCode}');
      debugPrint('Fail stop response body: ${response.body}');

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (json['success'] == true) {
          return Map<String, dynamic>.from(json);
        }
        throw Exception(json['message'] ?? 'Failed to fail stop');
      }

      throw Exception(json['message'] ?? 'Failed to fail stop');
    } catch (e) {
      debugPrint('Error failing stop: $e');
      throw Exception('Error failing stop: $e');
    }
  }

  Future<Map<String, dynamic>> retryStop({required int stopId}) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/order/stops/$stopId/retry');

      final response = await http
          .post(
            url,
            headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      debugPrint('Retry stop response status: ${response.statusCode}');
      debugPrint('Retry stop response body: ${response.body}');

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (json['success'] == true) {
          return Map<String, dynamic>.from(json);
        }
        throw Exception(json['message'] ?? 'Failed to retry stop');
      }

      throw Exception(json['message'] ?? 'Failed to retry stop');
    } catch (e) {
      debugPrint('Error retrying stop: $e');
      throw Exception('Error retrying stop: $e');
    }
  }
}
