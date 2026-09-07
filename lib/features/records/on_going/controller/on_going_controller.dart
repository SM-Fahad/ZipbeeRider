import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/service/order_feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class OnGoingController extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final ongoingOrders = <OrderModel>[].obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final hasMoreData = true.obs;
  late final ScrollController scrollController;

  final orderFeedService = OrderFeedService();

  // Logger instance
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      //printTime: true,
    ),
  );

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    fetchOnGoingOrders();
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
        isLoadingMore.value ||
        isLoading.value) {
      return;
    }

    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold && hasMoreData.value) {
      loadMore();
    }
  }

  Future<void> fetchOnGoingOrders({bool isRefresh = false}) async {
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

      logger.i("Fetching ongoing orders page ${currentPage.value}...");

      final response = await orderFeedService.fetchOnGoingOrders(
        page: currentPage.value,
        limit: 20,
      );

      if (isFirstPage) {
        ongoingOrders.assignAll(response.data);
      } else {
        ongoingOrders.addAll(response.data);
      }

      totalPages.value = response.totalPages;
      hasMoreData.value = currentPage.value < response.totalPages;
      errorMessage.value = '';
      logger.i("Fetched ${response.data.length} ongoing orders");
    } catch (e, stack) {
      logger.e("❌ API ERROR", error: e, stackTrace: stack);
      if (ongoingOrders.isEmpty) {
        errorMessage.value = 'Failed to fetch ongoing orders';
      } else {
        EasyLoading.showError('Failed to load more ongoing orders');
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await fetchOnGoingOrders(isRefresh: true);
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMoreData.value) {
      return;
    }

    currentPage.value++;
    await fetchOnGoingOrders();
  }
}
