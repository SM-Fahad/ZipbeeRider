import 'package:ZipBee_Driver/features/wallet_history/model/wallet_history_model.dart';
import 'package:ZipBee_Driver/features/wallet_history/service/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class WalletHistoryController extends GetxController {
  final WalletService _service = WalletService();
  final ScrollController scrollController = ScrollController();
  List<WalletHistory> transactions = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String selectedFilter = 'ALL'; // 'ALL', 'TIP'

  @override
  void onInit() {
    super.onInit();
    loadMoreData(); // Initial load

    scrollController.addListener(() {
      // Load more when user scrolls near bottom
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300) {
        loadMoreData();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void setFilter(String filter) {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    currentPage = 1;
    transactions.clear();
    hasMore = true;
    update();
    loadMoreData();
  }

  Future<void> loadMoreData() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    update();
    debugPrint('📥 WalletHistoryController: Loading page $currentPage, filter: $selectedFilter...');

    try {
      // Show loading indicator on first page
      if (currentPage == 1) {
        EasyLoading.show(status: 'Loading transaction history...');
      }

      final result = await _service.fetchHistory(
        currentPage,
        type: selectedFilter == 'ALL' ? null : selectedFilter,
      );
      final List<WalletHistory> newData = List<WalletHistory>.from(result['transactions'] ?? []);
      final bool serverHasMore = result['hasMore'] as bool? ?? false;

      debugPrint('✅ WalletHistoryController: Got ${newData.length} transactions for page $currentPage');

      if (newData.isEmpty) {
        hasMore = false;
        debugPrint('⚠️ WalletHistoryController: No more data available');
      } else {
        transactions.addAll(newData);
        currentPage++;
        hasMore = serverHasMore;
        debugPrint('✅ WalletHistoryController: Total transactions now: ${transactions.length}, hasMore: $hasMore');
      }
    } catch (e) {
      debugPrint('❌ WalletHistoryController Error: $e');
      EasyLoading.showError('Failed to load transactions');
    } finally {
      isLoading = false;
      EasyLoading.dismiss();
      update();
    }
  }

  Future<void> refreshData() async {
    currentPage = 1;
    transactions.clear();
    hasMore = true;
    await loadMoreData();
  }
}