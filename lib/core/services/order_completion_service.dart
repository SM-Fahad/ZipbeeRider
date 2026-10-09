import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderCompletionService {
  final baseUrl = ApiEndPoint.baseUrl;

  String _extractErrorMessage(
    dynamic json, {
    String fallback = 'Failed to complete stop',
  }) {
    if (json == null) return fallback;

    String? parseValue(dynamic val) {
      if (val == null) return null;
      if (val is String && val.trim().isNotEmpty) return val.trim();
      if (val is List && val.isNotEmpty) {
        final parts = val
            .map((e) => parseValue(e))
            .where((e) => e != null && e.isNotEmpty)
            .cast<String>()
            .toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
      if (val is Map) {
        if (val['message'] != null) {
          final m = parseValue(val['message']);
          if (m != null && m.isNotEmpty) return m;
        }
        if (val['error'] != null) {
          final m = parseValue(val['error']);
          if (m != null && m.isNotEmpty) return m;
        }
      }
      return null;
    }

    if (json is Map) {
      final error = json['error'];
      if (error is Map) {
        final resp = error['response'];
        if (resp != null) {
          final m = parseValue(resp is Map ? resp['message'] : resp);
          if (m != null && m.isNotEmpty) return m;
        }
        final m = parseValue(error['message']);
        if (m != null && m.isNotEmpty) return m;
      } else if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }

      if (json['message'] != null) {
        final m = parseValue(json['message']);
        if (m != null && m.isNotEmpty) return m;
      }
    } else if (json is List) {
      final m = parseValue(json);
      if (m != null && m.isNotEmpty) return m;
    } else if (json is String && json.trim().isNotEmpty) {
      return json.trim();
    }

    return fallback;
  }

  /// Complete a stop in an order
  /// Uploads proof photos and marks the stop as complete
  Future<Map<String, dynamic>> completeOrderStop({
    required int stopId,
    required List<String> proofUrls,
    String? notes,
    double? codCollected,
    double? additionalFee,
    String? additionalFeeReason,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse(ApiEndPoint.orderStopComplete(stopId));

      Future<http.Response> executePost(Map<String, dynamic> body) {
        return http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Request timeout'),
        );
      }

      final payload = <String, dynamic>{
        'proofUrls': proofUrls,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (codCollected != null) 'codCollected': codCollected,
        if (additionalFee != null && additionalFee > 0)
          'additionalFee': additionalFee,
        if (additionalFeeReason != null && additionalFeeReason.isNotEmpty)
          'additionalFeeReason': additionalFeeReason,
      };

      debugPrint('Completing stop $stopId with payload: $payload');
      debugPrint('Request URL: $url');

      var response = await executePost(payload);

      // Handle backend schema differences (proofUrls vs proofFiles or non-whitelisted fee fields)
      if (response.statusCode == 400) {
        final responseBody = response.body;
        var needsRetry = false;
        final retryPayload = Map<String, dynamic>.from(payload);

        if (responseBody.contains('proofUrls should not exist') ||
            responseBody.contains('proofFiles must be')) {
          retryPayload.remove('proofUrls');
          retryPayload['proofFiles'] = proofUrls;
          needsRetry = true;
        } else if (responseBody.contains('proofFiles should not exist')) {
          retryPayload.remove('proofFiles');
          retryPayload['proofUrls'] = proofUrls;
          needsRetry = true;
        }

        if (responseBody.contains('additionalFee should not exist')) {
          retryPayload.remove('additionalFee');
          retryPayload.remove('additionalFeeReason');
          needsRetry = true;
        }

        if (responseBody.contains('additionalFeeReason should not exist')) {
          retryPayload.remove('additionalFeeReason');
          needsRetry = true;
        }

        if (needsRetry) {
          debugPrint('Retrying stop completion with adjusted payload: $retryPayload');
          response = await executePost(retryPayload);
        }
      }

      debugPrint('Stop completion response status: ${response.statusCode}');
      debugPrint('Stop completion response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        if (json is Map<String, dynamic> && json['success'] == true) {
          debugPrint('Stop completed successfully');
          return json;
        } else {
          final errorMessage = _extractErrorMessage(
            json,
            fallback: 'Failed to complete stop',
          );
          throw Exception(errorMessage);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        dynamic json;
        try {
          json = jsonDecode(response.body);
        } catch (_) {
          json = null;
        }

        final errorMessage = _extractErrorMessage(
          json,
          fallback: 'Failed to complete stop (${response.statusCode})',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error completing stop: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error completing stop: $e');
    }
  }

  /// Stage / update stop additional fee before QR display or completion
  Future<Map<String, dynamic>> updateStopAdditionalFee({
    required int stopId,
    required double additionalFee,
    required String reason,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse(ApiEndPoint.orderStopAdditionalFee(stopId));
      final payload = {
        'additionalFee': additionalFee,
        'reason': reason,
      };

      debugPrint('Updating stop $stopId additional fee: $payload');
      debugPrint('Request URL: $url');

      final response = await http.patch(
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

      debugPrint('Stop additional fee response status: ${response.statusCode}');
      debugPrint('Stop additional fee response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic>) {
          return json;
        }
        return {'success': true, 'data': json};
      } else {
        dynamic json;
        try {
          json = jsonDecode(response.body);
        } catch (_) {
          json = null;
        }
        final errorMessage = _extractErrorMessage(
          json,
          fallback: 'Failed to update additional fee (${response.statusCode})',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error updating stop additional fee: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error updating stop additional fee: $e');
    }
  }
}

