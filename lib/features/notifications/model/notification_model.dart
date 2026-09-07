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
  final bool isActive;
  final bool isRead;
  final bool isFromAdmin;

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
    required this.isActive,
    required this.isRead,
    required this.isFromAdmin,
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

    return NotificationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: (json['type'] ?? '').toString(),
      title: json['title'] ?? '',
      subTitle: json['message'] ?? '',
      date: DateFormat('dd-MM-yyyy').format(createdAt),
      time: DateFormat('hh:mm a').format(createdAt),
      category: (json['category'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      targetRole: (json['target_role'] ?? '').toString(),
      orderId: json['orderId'] is int
          ? json['orderId'] as int
          : int.tryParse(json['orderId']?.toString() ?? ''),
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? ''),
      isActive: json['is_active'] == true,
      isFromAdmin: json['is_from_admin'] == true,
      isRead: json['is_read'] == true ||
          json['isReadByUser'] == true ||
          isMarkedByCurrentUser,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
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
      isActive: isActive,
      isRead: isRead ?? this.isRead,
      isFromAdmin: isFromAdmin,
    );
  }
}
