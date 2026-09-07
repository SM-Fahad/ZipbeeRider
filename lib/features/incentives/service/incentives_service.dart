import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/shared_prefs_service/shared_preference_helper.dart';
import '../model/incentive_model.dart';
import '../model/collect_incentive_model.dart';
import '../model/incentive_stats_model.dart';

class IncentivesService {
  final String baseUrl = ApiEndPoint.baseUrl;

  Future<String?> fetchAndSaveCurrentProfileIds() async {
    final token = await SharedPreferencesHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse(ApiEndPoint.getProfile),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(body['data'] ?? <String, dynamic>{});
    final raiderProfile = Map<String, dynamic>.from(
      data['raiderProfile'] ?? <String, dynamic>{},
    );

    final userId =
        raiderProfile['userId']?.toString() ?? data['id']?.toString();
    if (userId != null && userId.isNotEmpty) {
      await SharedPreferencesHelper.saveUserId(userId);
    }

    final raiderId = raiderProfile['id']?.toString();
    if (raiderId != null && raiderId.isNotEmpty) {
      await SharedPreferencesHelper.saveRaiderId(raiderId);
    }

    return userId;
  }

  ///  Fetch All Incentives API
  Future<List<IncentiveModel>> fetchIncentives() async {
    final token = await SharedPreferencesHelper.getAccessToken();

    if (token == null) {
      throw Exception("Token not found. Please login again.");
    }

    final url = Uri.parse('$baseUrl/incentive');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    debugPrint('All Incentive get response: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        // Check if the API response has success: false
        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Failed to fetch incentives');
        }

        final List<dynamic> incentivesList = data['data'] ?? [];
        return incentivesList
            .whereType<Map>()
            .map(
              (item) =>
                  IncentiveModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .where((incentive) => incentive.status.toUpperCase() == 'ACTIVE')
            .toList();
      } catch (e) {
        debugPrint('Error parsing incentives response: ${response.body}');
        rethrow;
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to fetch incentives');
      } catch (e) {
        throw Exception('Error (${response.statusCode}): ${response.body}');
      }
    }
  }

  ///  Collect Incentive API
  Future<CollectIncentiveResponseModel> collectIncentive(
    int incentiveId,
  ) async {
    final token = await SharedPreferencesHelper.getAccessToken();

    if (token == null) {
      throw Exception("Please login again to collect incentives");
    }

    final url = Uri.parse('$baseUrl/incentive/$incentiveId/collect');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    debugPrint('All Incentive get response: ${response.body}');

    try {
      final data = jsonDecode(response.body);

      // Check if the API response has success: false
      if (data['success'] == false) {
        final errorMsg =
            data['error']?['response']?['message'] ??
            data['message'] ??
            'Unable to collect incentive';

        // Make error messages more user-friendly
        String userFriendlyMsg = errorMsg;
        if (errorMsg.contains('already collected')) {
          userFriendlyMsg = "You've already collected this incentive! 🎉";
        } else if (errorMsg.contains('not found') ||
            errorMsg.contains('Not Found')) {
          userFriendlyMsg = "This incentive is no longer available";
        } else if (errorMsg.contains('expired')) {
          userFriendlyMsg = "This incentive has expired";
        }

        throw Exception(userFriendlyMsg);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = data['data'];

        if (responseData == null) {
          throw Exception('Something went wrong. Please try again.');
        }

        return CollectIncentiveResponseModel.fromJson(
          responseData as Map<String, dynamic>,
        );
      } else {
        throw Exception(data['message'] ?? 'Unable to collect incentive');
      }
    } catch (e) {
      debugPrint('Error collecting incentive: ${response.body}');
      rethrow;
    }
  }

  ///  Fetch Incentive Stats API
  Future<IncentiveStatsModel> fetchIncentiveStats() async {
    final token = await SharedPreferencesHelper.getAccessToken();

    if (token == null) {
      throw Exception("Token not found. Please login again.");
    }

    final url = Uri.parse('$baseUrl/incentive/stats');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        // Check if the API response has success: false
        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Failed to fetch incentive stats');
        }

        final statsData = data['data'];

        if (statsData == null) {
          debugPrint('API Response: $data');
          throw Exception(
            'Invalid response data: missing stats field. Response: $data',
          );
        }

        return IncentiveStatsModel.fromJson(statsData as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing stats response: ${response.body}');
        rethrow;
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to fetch incentive stats');
      } catch (e) {
        throw Exception('Error (${response.statusCode}): ${response.body}');
      }
    }
  }
}
