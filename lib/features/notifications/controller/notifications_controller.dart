import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/notifications/model/notification_model.dart';
import 'package:ZipBee_Driver/features/order_details/screen/order_details_screen.dart';
import 'package:ZipBee_Driver/features/order_details/service/order_details_service.dart';
import 'package:ZipBee_Driver/features/payment_method/screen/payment_method_screen.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/screen/dispute_screen.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationsController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isMarkingRead = false.obs;
  final RxInt page = 1.obs;
  final int limit = 10;
  bool hasMore = true;

  final RxList<NotificationModel> notificationList = <NotificationModel>[].obs;

  final List<String> tabs = ["Notification", "Promotion"];

  String get selectedCategory =>
      selectedTabIndex.value == 0 ? 'NOTIFICATION' : 'PROMOTION';

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (isLoading.value || (!hasMore && loadMore)) return;

    isLoading.value = true;

    try {
      if (loadMore) {
        page.value++;
      } else {
        page.value = 1;
        hasMore = true;
        notificationList.clear();
      }

      final token = await SharedPreferencesHelper.getAccessToken();
      final currentUserId = await SharedPreferencesHelper.getUserId();

      if (token == null || token.isEmpty) {
        EasyLoading.showError('Token not found');
        return;
      }

      final uri = Uri.parse(
        "${ApiEndPoint.notification}"
        "?page=${page.value}"
        "&limit=$limit"
        "&category=$selectedCategory",
      );

      debugPrint("fetchNotifications URL: $uri");

      final response = await http.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      debugPrint("fetchNotifications status: ${response.statusCode}");
      debugPrint("fetchNotifications body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded['data']?['data'] ?? [];
        final items = list
            .map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              map['_current_user_id'] = currentUserId;
              return NotificationModel.fromJson(map);
            })
            .where((item) => item.isActive)
            .toList();

        final int total = decoded['data']?['total'] ?? 0;
        hasMore = page.value * limit < total;

        notificationList.addAll(items);
      } else {
        if (loadMore) page.value--;
        debugPrint("fetchNotifications FAILED: ${response.statusCode} - ${response.body}");
        EasyLoading.showError('Failed (${response.statusCode})');
      }
    } catch (e, s) {
      if (loadMore) page.value--;
      debugPrint("Exception in fetchNotifications: $e\nStackTrace: $s");
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    if (selectedTabIndex.value != index) {
      selectedTabIndex.value = index;
      fetchNotifications();
    }
  }

  Future<void> onNotificationTap(NotificationModel item) async {
    if (!item.isRead && !isMarkingRead.value) {
      await markAsRead(item.id);
    }

    if (item.category.toUpperCase() == 'PROMOTION') {
      Get.toNamed('/notificationPromotionDetails', arguments: item);
      return;
    }

    switch (item.type.toUpperCase()) {
      case 'NEW_MESSAGE':
        final orderId = item.orderId;
        if (orderId == null) {
          EasyLoading.showError('Order ID not available');
          return;
        }
        try {
          EasyLoading.show(status: 'Loading chat details...');
          final order = await OrderDetailsService().fetchOrderDetail(orderId);
          EasyLoading.dismiss();

          Get.toNamed(
            AppRoutes.getRiderChatScreen(),
            arguments: {
              'receiverId': order.userId,
              'customerName': order.user.username,
              'orderId': order.id,
              'total': order.totalCost,
              'assignRiderPhone': order.user.phone,
              'vehicleType': order.vehicle.vehicleType,
            },
          );
        } catch (e) {
          EasyLoading.dismiss();
          EasyLoading.showError('Failed to load chat details');
          debugPrint("Error loading chat details: $e");
        }
        return;
      case 'FUNDS_FAILURE':
      case 'FUNDS_CREDITED':
        Get.to(() => PaymentMethodScreen());
        return;
      case 'ORDER_UPDATE':
        final orderId = item.orderId;
        if (orderId == null) {
          EasyLoading.showError('Order details not available');
          return;
        }
        Get.to(() => OrderDetailsScreen(), arguments: orderId);
        return;
      case 'DISPUTE_RESOLVED':
        Get.to(() => const DisputeScreen());
        return;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    isMarkingRead.value = true;
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final uri = Uri.parse(ApiEndPoint.notificationMarkAsRead(notificationId));
      final response = await http.patch(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      debugPrint("markAsRead URL: $uri");
      debugPrint("markAsRead status: ${response.statusCode}");
      debugPrint("markAsRead body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        EasyLoading.showError('Failed to mark as read');
        return;
      }

      final index =
          notificationList.indexWhere((e) => e.id == notificationId);
      if (index != -1) {
        notificationList[index] =
            notificationList[index].copyWith(isRead: true);
        notificationList.refresh();
      }
    } catch (e) {
      debugPrint("Exception in markAsRead: $e");
    } finally {
      isMarkingRead.value = false;
    }
  }

  void confirmDelete(String notificationId) {
    Get.defaultDialog(
      title: "Delete Notification",
      middleText: "Are you sure you want to delete this notification?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        deleteNotification(notificationId);
      },
    );
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      EasyLoading.show(status: "Deleting...");

      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError("Token not found");
        return false;
      }

      final uri = Uri.parse(
        ApiEndPoint.notificationID.replaceAll('{id}', notificationId),
      );

      final response = await http.delete(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      debugPrint("deleteNotification URL: $uri");
      debugPrint("deleteNotification status: ${response.statusCode}");
      debugPrint("deleteNotification body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          notificationList.removeWhere((e) => e.id == notificationId);
          EasyLoading.showSuccess(decoded['message'] ?? "Deleted successfully");
          return true;
        } else {
          EasyLoading.showError(decoded['message'] ?? "Delete failed");
          return false;
        }
      } else {
        EasyLoading.showError("Delete failed (${response.statusCode})");
        return false;
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
      debugPrint("Exception in deleteNotification: $e");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
