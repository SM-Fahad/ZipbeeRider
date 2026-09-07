import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/features/order_details/screen/order_details_screen.dart';
import 'package:ZipBee_Driver/features/records/on_going/controller/on_going_controller.dart';
import 'package:ZipBee_Driver/features/records/widgets/order_history_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnGoingScreen extends StatefulWidget {
  const OnGoingScreen({super.key});

  @override
  State<OnGoingScreen> createState() => _OnGoingScreenState();
}

class _OnGoingScreenState extends State<OnGoingScreen> {
  final OnGoingController controller = Get.put(OnGoingController());

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
        if (controller.isLoading.value && controller.ongoingOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.ongoingOrders.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.fetchOnGoingOrders,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: controller.refreshOrders,
            child: ListView.separated(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: controller.ongoingOrders.isEmpty
                  ? 1
                  : controller.ongoingOrders.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (controller.ongoingOrders.isEmpty) {
                  return SizedBox(
                    height: constraints.maxHeight - 32,
                    child: const Center(child: Text("No ongoing orders")),
                  );
                }

                if (index == controller.ongoingOrders.length) {
                  return _PaginationFooter(
                    isLoadingMore: controller.isLoadingMore.value,
                    hasMoreData: controller.hasMoreData.value,
                  );
                }

                final order = controller.ongoingOrders[index];
                return OrderHistoryCard(
                  order: order,
                  defaultStatusLabel: 'PENDING',
                  onTap: () {
                    Get.to(
                      () => OrderDetailsScreen(),
                      arguments: {
                        'order': order,
                        'fromOngoing': true,
                      },
                    )?.then((result) {
                      if (result == 'completed') {
                        controller.refreshOrders();
                      }
                    });
                  },
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
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: Get.back,
      ),
      title: Text(
        "On-going orders",
        style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
