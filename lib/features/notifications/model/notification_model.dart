import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String subTitle;
  final String date;
  final String time;
  final String category;
  final String imageUrl;
  final String targetRole;
  final int? orderId;
  final int? userId;
  final int? disputeId;
  final String? orderNumber;
  final String? redirectType;
  final String? screen;
  final bool isActive;
  final bool isRead;
  final bool isFromAdmin;
  final Map<String, dynamic>? rawData;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subTitle,
    required this.date,
    required this.time,
    required this.category,
    required this.imageUrl,
    required this.targetRole,
    required this.orderId,
    this.userId,
    this.disputeId,
    this.orderNumber,
    this.redirectType,
    this.screen,
    required this.isActive,
    required this.isRead,
    required this.isFromAdmin,
    this.rawData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['createdAt'] ?? json['created_at'];
    final createdAt = createdAtStr != null
        ? DateTime.parse(createdAtStr).toLocal()
        : DateTime.now();

    final markAsReadIds = (json['mark_as_read_id'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final currentUserId = json['_current_user_id']?.toString();
    final isMarkedByCurrentUser =
        currentUserId != null && markAsReadIds.contains(currentUserId);

    // Extract nested data payload if available
    final dynamic rawDataPayload = json['data'];
    final Map<String, dynamic>? dataMap = rawDataPayload is Map<String, dynamic>
        ? rawDataPayload
        : (rawDataPayload is Map ? Map<String, dynamic>.from(rawDataPayload) : null);

    final rawOrderId =
        json['orderId'] ?? dataMap?['orderId'] ?? dataMap?['order_id'];
    final int? orderId = rawOrderId is int
        ? rawOrderId
        : int.tryParse(rawOrderId?.toString() ?? '');

    final rawDisputeId = json['disputeId'] ??
        json['orderDisputeId'] ??
        dataMap?['disputeId'] ??
        dataMap?['orderDisputeId'];
    final int? disputeId = rawDisputeId is int
        ? rawDisputeId
        : int.tryParse(rawDisputeId?.toString() ?? '');

    final String? orderNumber = json['orderNumber']?.toString() ??
        dataMap?['orderNumber']?.toString() ??
        json['order_number']?.toString() ??
        dataMap?['order_number']?.toString();

    final String? redirectType =
        json['redirectType']?.toString() ?? dataMap?['redirectType']?.toString();

    final String? screen =
        json['screen']?.toString() ?? dataMap?['screen']?.toString();

    final String type = (json['type'] ?? dataMap?['type'] ?? '').toString();
    final String rawMessage = (json['message'] ?? json['body'] ?? dataMap?['body'] ?? '').toString();

    final formattedSubTitle = _formatNotificationSubtitle(
      rawMessage: rawMessage,
      type: type,
      orderId: orderId,
      orderNumber: orderNumber,
    );

    return NotificationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: type,
      title: json['title'] ?? '',
      subTitle: formattedSubTitle,
      date: DateFormat('dd-MM-yyyy').format(createdAt),
      time: DateFormat('hh:mm a').format(createdAt),
      category: (json['category'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      targetRole: (json['target_role'] ?? '').toString(),
      orderId: orderId,
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? ''),
      disputeId: disputeId,
      orderNumber: orderNumber,
      redirectType: redirectType,
      screen: screen,
      isActive: json['is_active'] == true,
      isFromAdmin: json['is_from_admin'] == true,
      isRead: json['is_read'] == true ||
          json['isReadByUser'] == true ||
          isMarkedByCurrentUser,
      rawData: dataMap,
    );
  }

  static String _formatNotificationSubtitle({
    required String rawMessage,
    required String type,
    int? orderId,
    String? orderNumber,
  }) {
    if (rawMessage.trim().isEmpty) return '';

    // 1. Format unrounded floating point numbers (3+ decimal places) to 2 decimal places
    String message = rawMessage.replaceAllMapped(
      RegExp(r'(\d+\.\d{3,})'),
      (match) {
        final val = double.tryParse(match.group(1) ?? '');
        return val != null ? val.toStringAsFixed(2) : match.group(0)!;
      },
    );

    // 2. Handle DISPUTE_RESOLVED notifications
    if (type.toUpperCase() == 'DISPUTE_RESOLVED') {
      // Ensure currency dollar symbol is formatted for Deducted
      message = message.replaceAllMapped(
        RegExp(r'Deducted:\s*([0-9]+(?:\.[0-9]{1,2})?)'),
        (m) => 'Deducted: \$${m.group(1)}',
      );

      final orderIdentifier = (orderNumber != null && orderNumber.isNotEmpty)
          ? orderNumber
          : (orderId != null ? 'ORD-${orderId.toString().padLeft(6, '0')}' : null);

      final hasOrderMention =
          RegExp(r'(order|ord-)', caseSensitive: false).hasMatch(message);

      if (!hasOrderMention && orderIdentifier != null) {
        if (message.toLowerCase().startsWith('deducted')) {
          message = 'Dispute resolved for order $orderIdentifier. $message';
        } else {
          message = 'Order $orderIdentifier • $message';
        }
      }
    }

    return message;
  }

  NotificationModel copyWith({
    bool? isRead,
    int? disputeId,
    String? orderNumber,
    String? redirectType,
    String? screen,
    Map<String, dynamic>? rawData,
  }) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      subTitle: subTitle,
      date: date,
      time: time,
      category: category,
      imageUrl: imageUrl,
      targetRole: targetRole,
      orderId: orderId,
      userId: userId,
      disputeId: disputeId ?? this.disputeId,
      orderNumber: orderNumber ?? this.orderNumber,
      redirectType: redirectType ?? this.redirectType,
      screen: screen ?? this.screen,
      isActive: isActive,
      isRead: isRead ?? this.isRead,
      isFromAdmin: isFromAdmin,
      rawData: rawData ?? this.rawData,
    );
  }
}
