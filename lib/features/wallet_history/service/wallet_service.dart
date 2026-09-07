import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/wallet_history/model/wallet_history_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class WalletService {
  Future<Map<String, dynamic>> fetchHistory(int page) async {
    try {
      // Get userId from SharedPreferences
      var userId = await SharedPreferencesHelper.getUserId();
      
      if (userId == null || userId.isEmpty) {
        debugPrint('⚠️ Wallet Service: userId not found, fetching from profile...');
        // Fallback: Fetch profile to get userId
        final token = await SharedPreferencesHelper.getAccessToken();
        if (token != null) {
          final profileResponse = await http.get(
            Uri.parse(ApiEndPoint.getProfile),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (profileResponse.statusCode == 200) {
            final profileData = jsonDecode(profileResponse.body)['data'];
            userId = profileData['id']?.toString();
            
            if (userId != null && userId.isNotEmpty) {
              // Save for future use
              await SharedPreferencesHelper.saveUserId(userId);
              debugPrint('✅ Wallet Service: Fetched and saved userId=$userId from profile');
            }
          }
        }
      }
      
      if (userId == null || userId.isEmpty) {
        debugPrint('❌ Wallet Service: No userId found in SharedPreferences');
        EasyLoading.showError('User not authenticated. Please login again.');
        throw Exception('User ID not found. Please login again.');
      }

      debugPrint('📡 Wallet Service: Fetching history for userId=$userId, page=$page');

      // Get token for authentication
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Build URL using ApiEndPoint
      final baseUrl = ApiEndPoint.getWalletHistory(userId);
      final url = '$baseUrl?page=$page&limit=20';
      debugPrint('📍 Wallet Service URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Wallet Service: Response status code = ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        final int total = body['total'] as int? ?? 0;
        final int limit = body['limit'] as int? ?? 20;

        debugPrint('✅ Wallet Service: Fetched ${data.length} total records');

        // Filter only "SUCCESS" status transactions
        final filteredData = data
            .map((item) => WalletHistory.fromJson(item))
            .where((item) => item.status == "SUCCESS")
            .toList();

        debugPrint('✅ Wallet Service: Filtered to ${filteredData.length} SUCCESS records');
        
        final bool hasMore = (page * limit) < total;

        return {
          'transactions': filteredData,
          'hasMore': hasMore,
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('❌ Wallet Service: Unauthorized (${response.statusCode})');
        EasyLoading.showError('Session expired. Please login again.');
        throw Exception('Unauthorized: ${response.statusCode}');
      } else {
        debugPrint('❌ Wallet Service: Failed with status ${response.statusCode}');
        EasyLoading.showError('Failed to load wallet history');
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Wallet Service Exception: $e');
      rethrow;
    }
  }
}