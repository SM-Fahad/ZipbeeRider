import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/controller/create_dispute_appeal_controller.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/controller/create_dispute_controller.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/screen/create_dispute_appeal_screen.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/screen/create_dispute_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DisputeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Map<String, dynamic>> disputes = <Map<String, dynamic>>[].obs;
  final RxInt totalCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;
  final int limit = 10;
  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    fetchDisputes();
  }

  @override
  void onClose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients ||
        isLoading.value ||
        isLoadingMore.value ||
        !hasMoreData.value) {
      return;
    }

    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold) {
      loadMoreDisputes();
    }
  }

  Future<void> fetchDisputes({
    bool showLoader = true,
    bool loadMore = false,
  }) async {
    if (isLoading.value || isLoadingMore.value) return;
    if (loadMore && !hasMoreData.value) return;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
        currentPage.value++;
      } else {
        currentPage.value = 1;
        totalPages.value = 1;
        hasMoreData.value = true;
        disputes.clear();
      }

      if (showLoader && !loadMore) {
        isLoading.value = true;
      }

      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        disputes.clear();
        totalCount.value = 0;
        EasyLoading.showError('Access token not found');
        return;
      }

      final response = await http.get(
        Uri.parse(
          ApiEndPoint.getDisputes(page: currentPage.value, limit: limit),
        ),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final items = (data['data'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        final meta = data['meta'] as Map<String, dynamic>? ?? {};

        if (loadMore) {
          disputes.addAll(items);
        } else {
          disputes.assignAll(items);
        }
        totalCount.value = (meta['total'] as num?)?.toInt() ?? items.length;
        totalPages.value = (meta['totalPages'] as num?)?.toInt() ?? 1;
        hasMoreData.value = currentPage.value < totalPages.value;
        return;
      }

      if (loadMore) {
        currentPage.value--;
      } else {
        disputes.clear();
        totalCount.value = 0;
      }
      EasyLoading.showError(
        body['message']?.toString() ?? 'Failed to load disputes',
      );
    } catch (e) {
      if (loadMore) {
        currentPage.value--;
      } else {
        disputes.clear();
        totalCount.value = 0;
      }
      debugPrint('Dispute fetch error: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshDisputes() async {
    await fetchDisputes(showLoader: false);
  }

  Future<void> loadMoreDisputes() async {
    await fetchDisputes(loadMore: true, showLoader: false);
  }

  Future<void> openCreateDispute() async {
    if (Get.isRegistered<CreateDisputeController>()) {
      Get.delete<CreateDisputeController>(force: true);
    }
    final created = await Get.to<bool>(() => const CreateDisputeScreen());
    if (created == true) {
      await fetchDisputes(showLoader: false);
    }
  }

  Future<void> openCreateAppeal({
    required int orderDisputeId,
    required int orderId,
  }) async {
    if (Get.isRegistered<CreateDisputeAppealController>()) {
      Get.delete<CreateDisputeAppealController>(force: true);
    }
    final created = await Get.to<bool>(
      () => CreateDisputeAppealScreen(
        orderDisputeId: orderDisputeId,
        orderId: orderId,
      ),
    );
    if (created == true) {
      await fetchDisputes(showLoader: false);
    }
  }
}
