import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/service/order_feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CompleteOrdersController extends GetxController {
  final completedOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final hasMoreData = true.obs;
  late final ScrollController scrollController;

  final orderFeedService = OrderFeedService();
  final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    fetchCompletedOrders();
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
        isLoadingMore.value) {
      return;
    }

    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold && hasMoreData.value) {
      loadMore();
    }
  }

  Future<void> fetchCompletedOrders({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        totalPages.value = 1;
        hasMoreData.value = true;
        errorMessage.value = '';
      }

      final isFirstPage = currentPage.value == 1;
      if (isFirstPage) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      logger.i('Fetching completed orders page ${currentPage.value}');

      final response = await orderFeedService.fetchCompletedOrders(
        page: currentPage.value,
        limit: 20,
      );

      if (isFirstPage) {
        completedOrders.assignAll(response.data);
      } else {
        completedOrders.addAll(response.data);
      }

      totalPages.value = response.totalPages;
      hasMoreData.value = currentPage.value < response.totalPages;
      errorMessage.value = '';
    } catch (e, stack) {
      logger.e('Error fetching completed orders', error: e, stackTrace: stack);
      if (completedOrders.isEmpty) {
        errorMessage.value = 'Failed to load completed orders';
      } else {
        EasyLoading.showError('Failed to load more completed orders');
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await fetchCompletedOrders(isRefresh: true);
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMoreData.value) {
      return;
    }

    currentPage.value++;
    await fetchCompletedOrders();
  }
}
