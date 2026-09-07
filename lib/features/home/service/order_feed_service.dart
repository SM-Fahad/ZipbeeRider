import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/services/app_http_client.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../model/order_model.dart';

class OrderFeedResponse {
  final List<OrderModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  OrderFeedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory OrderFeedResponse.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('Parsing OrderFeedResponse from JSON: ${json.keys}');

      // Handle nested data structure: { data: { data: [...], total, page, limit, totalPages } }
      final dataWrapper = json['data'];
      debugPrint(
        'Data wrapper type: ${dataWrapper.runtimeType}, value: $dataWrapper',
      );

      Map<String, dynamic>? dataJson;
      if (dataWrapper is Map<String, dynamic>) {
        dataJson = dataWrapper;
      } else if (dataWrapper is Map) {
        dataJson = Map<String, dynamic>.from(dataWrapper);
      } else {
        debugPrint(
          'Warning: data wrapper is not a Map, it is: ${dataWrapper.runtimeType}',
        );
        dataJson = null;
      }

      List<OrderModel> ordersList = [];
      if (dataJson != null) {
        final ordersData = dataJson['data'];
        debugPrint(
          'Orders data type: ${ordersData.runtimeType}, count: ${ordersData is List ? ordersData.length : 'N/A'}',
        );

        if (ordersData is List) {
          ordersList = ordersData
              .map((item) {
                try {
                  if (item is Map<String, dynamic>) {
                    return OrderModel.fromJson(item);
                  } else if (item is Map) {
                    return OrderModel.fromJson(Map<String, dynamic>.from(item));
                  }
                } catch (e) {
                  debugPrint('Error parsing order item: $e');
                }
                return null;
              })
              .whereType<OrderModel>()
              .toList();
          debugPrint('Successfully parsed ${ordersList.length} orders');
        }
      }

      return OrderFeedResponse(
        data: ordersList,
        total: dataJson?['total'] as int? ?? 0,
        page: dataJson?['page'] as int? ?? 1,
        limit: dataJson?['limit'] as int? ?? 20,
        totalPages: dataJson?['totalPages'] as int? ?? 1,
      );
    } catch (e, stack) {
      debugPrint('Error parsing OrderFeedResponse: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }
}

class OrderFeedService {
  final baseUrl = ApiEndPoint.baseUrl;

  Future<OrderFeedResponse> fetchRiderOrdersByStatus(
    String status, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      debugPrint('token: $token');

      final url = Uri.parse(
        '$baseUrl/order/raider/mine?status=$status&page=$page&limit=$limit',
      );

      debugPrint('Fetching rider orders from: $url');

      final response = await AppHttpClient
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      debugPrint('Rider orders response status: ${response.statusCode}');
      debugPrint('Rider orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return OrderFeedResponse.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to load $status orders: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching $status orders: $e');
      throw Exception('Error fetching $status orders: $e');
    }
  }

  Future<OrderFeedResponse> fetchOrderFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Get the access token from shared preferences
      final token = await SharedPreferencesHelper.getAccessToken();
      debugPrint('token: $token');
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/order/feed?page=$page&limit=$limit');

      final response = await AppHttpClient
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      debugPrint('Order feed response status: ${response.statusCode}');
      debugPrint('Order feed response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return OrderFeedResponse.fromJson(json);
      } else if (response.statusCode == 401) {
        Get.offAllNamed(AppRoutes.loginSignupScreen);
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  /// Fetch ongoing orders for the rider
  Future<OrderFeedResponse> fetchOnGoingOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return fetchRiderOrdersByStatus('ONGOING', page: page, limit: limit);
  }

  /// Accept an order by joining the competition
  Future<Map<String, dynamic>> acceptOrderCompetition(int orderId) async {
    try {
      // Get the access token from shared preferences
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/order/driver/compitition/$orderId');

      debugPrint('Accepting order: $orderId');

      final response = await AppHttpClient
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      debugPrint('Accept order response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Failed to accept order';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Error accepting order: $e');
    }
  }

  /// Decline an order
  Future<Map<String, dynamic>> declineOrder(int orderId) async {
    try {
      // Get the access token from shared preferences
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/order/decline/$orderId');

      debugPrint('Declining order: $orderId');

      final response = await AppHttpClient
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      debugPrint('Decline order response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        fetchOrderFeed();
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Failed to decline order';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Error declining order: $e');
    }
  }

  /// Fetch completed orders for the rider
  Future<OrderFeedResponse> fetchCompletedOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return fetchRiderOrdersByStatus('COMPLETED', page: page, limit: limit);
  }

  Future<OrderFeedResponse> fetchCancelledOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return fetchRiderOrdersByStatus('CANCELLED', page: page, limit: limit);
  }
}
