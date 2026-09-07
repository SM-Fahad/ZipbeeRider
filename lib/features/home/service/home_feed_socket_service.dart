import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ZipBee_Driver/core/services/socket_service.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';

class HomeFeedSocketService {
  final SocketService _socketService = SocketService();

  /// Registered callbacks
  void Function(List<OrderModel> orders, int total, Map<String, dynamic>? raiderInfo)? _onFeedUpdate;
  void Function(String errorMsg, int? code)? _onFeedError;
  void Function(int orderId, String message)? _onOrderDeclined;

  /// Setup socket listeners for home feed
  void initialize({
    required void Function(List<OrderModel> orders, int total, Map<String, dynamic>? raiderInfo) onFeedUpdate,
    required void Function(String errorMsg, int? code) onFeedError,
    required void Function(int orderId, String message) onOrderDeclined,
  }) {
    _onFeedUpdate = onFeedUpdate;
    _onFeedError = onFeedError;
    _onOrderDeclined = onOrderDeclined;

    // Listen to feed_update
    _socketService.on('rider:feed_update', _handleFeedUpdate);

    // Listen to feed_error
    _socketService.on('rider:feed_error', _handleFeedError);

    // Listen to order_declined
    _socketService.on('rider:order_declined', _handleOrderDeclined);
    
    // Listen to get_feed if there is any response or debug event
    _socketService.on('rider:get_feed', (data) {
      debugPrint('[SOCKET] rider:get_feed event hit');
      _debugPrintLargeJson(data);
    });
  }

  /// Clean up socket listeners
  void dispose() {
    _socketService.off('rider:feed_update');
    _socketService.off('rider:feed_error');
    _socketService.off('rider:order_declined');
    _socketService.off('rider:get_feed');
    _onFeedUpdate = null;
    _onFeedError = null;
    _onOrderDeclined = null;
  }

  /// Request feed refresh
  void refreshFeed({int page = 1, int limit = 100}) {
    debugPrint('[SOCKET] Emitting rider:get_feed (page: $page, limit: $limit)');
    _socketService.emit('rider:get_feed', {
      'page': page,
      'limit': limit,
    });
  }

  /// Handle incoming feed update
  void _handleFeedUpdate(dynamic payload) {
    debugPrint('[SOCKET] Received rider:feed_update payload');
    _debugPrintLargeJson(payload);

    if (payload == null) {
      debugPrint('[SOCKET] Payload is null, skipping update.');
      return;
    }

    try {
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(payload as Map);
      
      final dynamic rawData = dataMap['data'];
      final int total = dataMap['total'] as int? ?? 0;
      final Map<String, dynamic>? raiderInfo = dataMap['raiderInfo'] != null 
          ? Map<String, dynamic>.from(dataMap['raiderInfo'] as Map)
          : null;

      List<OrderModel> parsedOrders = [];
      if (rawData is List) {
        parsedOrders = rawData
            .map((item) {
              try {
                if (item is Map) {
                  return OrderModel.fromJson(Map<String, dynamic>.from(item));
                }
              } catch (e) {
                debugPrint('[SOCKET] Error parsing order item: $e');
              }
              return null;
            })
            .whereType<OrderModel>()
            .toList();
      }

      if (_onFeedUpdate != null) {
        _onFeedUpdate!(parsedOrders, total, raiderInfo);
      }
    } catch (e, stackTrace) {
      debugPrint('[SOCKET] Error handling feed update: $e');
      debugPrint('[SOCKET] Stacktrace: $stackTrace');
    }
  }

  /// Handle incoming feed error
  void _handleFeedError(dynamic errorData) {
    debugPrint('[SOCKET] Received rider:feed_error payload');
    _debugPrintLargeJson(errorData);

    if (errorData == null) return;

    try {
      final Map<String, dynamic> errorMap = Map<String, dynamic>.from(errorData as Map);
      final String message = errorMap['message']?.toString() ?? 'Unknown feed error';
      final int? code = errorMap['code'] as int?;

      if (_onFeedError != null) {
        _onFeedError!(message, code);
      }
    } catch (e) {
      debugPrint('[SOCKET] Error handling feed error payload: $e');
    }
  }

  /// Handle order declined event
  void _handleOrderDeclined(dynamic payload) {
    debugPrint('[SOCKET] Received rider:order_declined payload');
    _debugPrintLargeJson(payload);

    if (payload == null) return;

    try {
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(payload as Map);
      final int? orderId = dataMap['orderId'] as int?;
      final String message = dataMap['message']?.toString() ?? 'Order removed from your feed';

      if (orderId != null && _onOrderDeclined != null) {
        _onOrderDeclined!(orderId, message);
      }
    } catch (e) {
      debugPrint('[SOCKET] Error handling order declined payload: $e');
    }
  }

  /// Custom logger to print large JSON completely and beautifully without truncation
  void _debugPrintLargeJson(dynamic data) {
    try {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String prettyJson = encoder.convert(data);
      final List<String> lines = prettyJson.split('\n');
      
      debugPrint('================ SOCKET DATA LOG START (Lines: ${lines.length}) ================');
      for (final line in lines) {
        debugPrint(line);
      }
      debugPrint('================ SOCKET DATA LOG END ================');
    } catch (e) {
      // Fallback in case of prettify failure
      final String plainText = data.toString();
      debugPrint('================ SOCKET DATA LOG START (Raw Length: ${plainText.length}) ================');
      const int wrapLength = 800;
      int start = 0;
      while (start < plainText.length) {
        int end = start + wrapLength;
        if (end > plainText.length) end = plainText.length;
        debugPrint(plainText.substring(start, end));
        start = end;
      }
      debugPrint('================ SOCKET DATA LOG END ================');
    }
  }
}
