import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/payment_method/model/stripe_account_response.dart';
import 'package:ZipBee_Driver/features/payment_method/model/withdraw_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PaymentMethodService {
  // Create Stripe Express Account
  static Future<StripeAccountResponse?> createExpressAccount() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        return null;
      }

      final response = await http.post(
        Uri.parse(ApiEndPoint.createExpressAccount),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ); 

      debugPrint('Stripe Express Account Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return StripeAccountResponse.fromJson(decoded);
      } else {
        try {
          final decoded = jsonDecode(response.body);
          final message = decoded['message'] ?? decoded['error'] ?? 'HTTP Error ${response.statusCode}';
          return StripeAccountResponse(
            success: false,
            message: message.toString(),
            data: AccountLinkData(object: '', created: 0, expiresAt: 0, url: ''),
          );
        } catch (_) {
          return StripeAccountResponse(
            success: false,
            message: 'Failed with status code: ${response.statusCode}',
            data: AccountLinkData(object: '', created: 0, expiresAt: 0, url: ''),
          );
        }
      }
    } catch (e) {
      print('Error creating express account: $e');
      return StripeAccountResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: AccountLinkData(object: '', created: 0, expiresAt: 0, url: ''),
      );
    }
  }

  // Reset Stripe Express Account
  static Future<StripeAccountResponse?> resetExpressAccount() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        return null;
      }

      final response = await http.post(
        Uri.parse(ApiEndPoint.resetExpressAccount),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ); 

      debugPrint('Reset Stripe Express Account Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return StripeAccountResponse.fromJson(decoded);
      } else {
        try {
          final decoded = jsonDecode(response.body);
          final message = decoded['message'] ?? decoded['error'] ?? 'HTTP Error ${response.statusCode}';
          return StripeAccountResponse(
            success: false,
            message: message.toString(),
            data: AccountLinkData(object: '', created: 0, expiresAt: 0, url: ''),
          );
        } catch (_) {
          return StripeAccountResponse(
            success: false,
            message: 'Failed with status code: ${response.statusCode}',
            data: AccountLinkData(object: '', created: 0, expiresAt: 0, url: ''),
          );
        }
      }
    } catch (e) {
      print('Error resetting express account: $e');
      return StripeAccountResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: AccountLinkData(object: '', created: 0, expiresAt: 0, url: ''),
      );
    }
  }

  // Withdraw Money
  static Future<WithdrawResponse?> withdrawMoney(double amount) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        debugPrint('❌ Withdraw: Token is null');
        return null;
      }

      final body = {
        'amount': amount,
        'currency': 'sgd',
      };

      final url = Uri.parse(ApiEndPoint.withdraw);
      debugPrint('➡️ Withdraw Request URL: $url');
      debugPrint('➡️ Withdraw Request Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint('⬅️ Withdraw Response Status: ${response.statusCode}');
      debugPrint('⬅️ Withdraw Response Body: ${response.body}');

      if (response.body.isEmpty) {
        debugPrint('❌ Withdraw: Response body is empty');
        return WithdrawResponse(
          success: false,
          statusCode: response.statusCode,
          message: 'Empty response from server',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final bool success = decoded['success'] == true || 
                             response.statusCode == 200 || 
                             response.statusCode == 201;
                             
        final String message = decoded['message']?.toString() ?? 
                               decoded['error']?.toString() ?? 
                               '';
                               
        final int statusCode = decoded['statusCode'] as int? ?? response.statusCode;

        return WithdrawResponse(
          success: success,
          statusCode: statusCode,
          message: message.isNotEmpty ? message : 'Response Code: $statusCode',
          data: decoded['data'],
        );
      } else {
        return WithdrawResponse(
          success: response.statusCode == 200 || response.statusCode == 201,
          statusCode: response.statusCode,
          message: 'Unexpected response format',
        );
      }
    } catch (e) {
      debugPrint('❌ Error withdrawing money: $e');
      return WithdrawResponse(
        success: false,
        statusCode: 500,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }
}
