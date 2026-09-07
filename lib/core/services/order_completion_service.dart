import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderCompletionService {
  final baseUrl = ApiEndPoint.baseUrl;

  /// Complete a stop in an order
  /// Uploads proof photos and marks the stop as complete
  Future<Map<String, dynamic>> completeOrderStop({
    required int stopId,
    required List<String> proofUrls,
    String? notes,
    double? codCollected,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/order/stops/$stopId/complete');
      
      final payload = {
        'proofUrls': proofUrls,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (codCollected != null) 'codCollected': codCollected,
      };

      debugPrint('Completing stop $stopId with payload: $payload');
      debugPrint('Request URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Stop completion response status: ${response.statusCode}');
      debugPrint('Stop completion response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          debugPrint('Stop completed successfully');
          return json;
        } else {
          // Extract nested error message
          String errorMessage = 'Failed to complete stop';
          
          if (json['error'] is Map<String, dynamic>) {
            final errorObj = json['error'] as Map<String, dynamic>;
            
            // Try to get message from nested response
            if (errorObj['response'] is Map<String, dynamic>) {
              final responseObj = errorObj['response'] as Map<String, dynamic>;
              errorMessage = responseObj['message'] ?? errorObj['message'] ?? errorMessage;
            } else {
              errorMessage = errorObj['message'] ?? json['message'] ?? errorMessage;
            }
          } else {
            errorMessage = json['message'] ?? errorMessage;
          }
          
          throw Exception(errorMessage);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        final json = jsonDecode(response.body);
        
        // Extract nested error message for non-200/201 responses
        String errorMessage = 'Failed to complete stop';
        if (json['error'] is Map<String, dynamic>) {
          final errorObj = json['error'] as Map<String, dynamic>;
          if (errorObj['response'] is Map<String, dynamic>) {
            final responseObj = errorObj['response'] as Map<String, dynamic>;
            errorMessage = responseObj['message'] ?? errorObj['message'] ?? errorMessage;
          } else {
            errorMessage = errorObj['message'] ?? json['message'] ?? errorMessage;
          }
        } else {
          errorMessage = json['message'] ?? errorMessage;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error completing stop: $e');
      throw Exception('Error completing stop: $e');
    }
  }
}
