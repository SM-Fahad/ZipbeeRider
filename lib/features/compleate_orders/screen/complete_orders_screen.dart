import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/features/compleate_orders/controller/complete_orders_controller.dart';
import 'package:ZipBee_Driver/features/order_details/screen/order_details_screen.dart';
import 'package:ZipBee_Driver/features/records/widgets/order_history_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompleteOrdersScreen extends StatefulWidget {
  const CompleteOrdersScreen({super.key});

  @override
  State<CompleteOrdersScreen> createState() => _CompleteOrdersScreenState();
}

class _CompleteOrdersScreenState extends State<CompleteOrdersScreen> {
  final CompleteOrdersController controller = Get.put(CompleteOrdersController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value && controller.completedOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.completedOrders.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.fetchCompletedOrders,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: controller.refreshOrders,
            child: ListView.separated(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: controller.completedOrders.isEmpty
                  ? 1
                  : controller.completedOrders.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (controller.completedOrders.isEmpty) {
                  return SizedBox(
                    height: constraints.maxHeight - 32,
                    child: const Center(child: Text('No completed orders')),
                  );
                }

                if (index == controller.completedOrders.length) {
                  return _PaginationFooter(
                    isLoadingMore: controller.isLoadingMore.value,
                    hasMoreData: controller.hasMoreData.value,
                  );
                }

                final order = controller.completedOrders[index];
                return OrderHistoryCard(
                  order: order,
                  defaultStatusLabel: 'COMPLETED',
                  onTap: () =>
                      Get.to(() => OrderDetailsScreen(), arguments: order),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: Get.back,
      ),
      title: Text(
        "Completed orders",
        style: getTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoadingMore,
    required this.hasMoreData,
  });

  final bool isLoadingMore;
  final bool hasMoreData;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!hasMoreData) {
      return const SizedBox.shrink();
    }

    return const SizedBox(height: 8);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: getTextStyle(fontSize: 16, color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
