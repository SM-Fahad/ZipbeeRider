import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/home/controller/home_controller.dart';
import 'package:ZipBee_Driver/features/home/widgets/rider_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController(), permanent: true);

    ctrl.subscribeRoute(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => AppBar(
            backgroundColor: Colors.white,
            elevation: 6,
            shadowColor: Colors.grey.withValues(alpha: 0.4),
            centerTitle: true,
            title: Text(
              ctrl.isOnline.value ? 'Online' : 'Offline',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            leadingWidth: 80,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.primaryFontColor,
                    ),
                    onSelected: (value) {
                      if (value == 'refresh_rate') {
                        ctrl.showFeedRefreshRateBottomSheet(context);
                      } else if (value == 'reset_feed') {
                        ctrl.resetOrderFeed();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'refresh_rate',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, color: Colors.black87, size: 20),
                            SizedBox(width: 10),
                            Text('Feed Refresh Rate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'reset_feed',
                        child: Row(
                          children: [
                            Icon(Icons.restart_alt, color: Colors.black87, size: 20),
                            SizedBox(width: 10),
                            Text('Order Feed Reset'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Obx(
                    () => IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: AppColors.primaryFontColor,
                          ),
                          if (ctrl.unreadNotificationCount.value > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                constraints: const BoxConstraints(minWidth: 18),
                                child: Text(
                                  ctrl.unreadNotificationCount.value > 9
                                      ? '9+'
                                      : '${ctrl.unreadNotificationCount.value}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () async {
                        await Get.toNamed('/notifications');
                        await ctrl.fetchUnreadNotificationCount();
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Switch(
                value: ctrl.isOnline.value,
                onChanged: (value) async {
                  await ctrl.handleOnlineSwitchChange(value);
                  // Don't remove next line. Important for auto reload  when online                  
                  await ctrl.refreshOrders();
                },
                activeThumbColor: AppColors.primaryButtonColor,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: ctrl.refreshOrders,
            child: ListView.builder(
              controller: ctrl.scrollController,
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: ctrl.orders.isEmpty
                  ? 1
                  : ctrl.orders.length + (ctrl.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (ctrl.orders.isEmpty) {
                  return SizedBox(
                    height: constraints.maxHeight - 24,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No orders available',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: ctrl.refreshOrders,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (index == ctrl.orders.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final order = ctrl.orders[index];
                return RiderCardWidget(order: order, index: index, ctrl: ctrl);
              },
            ),
          ),
        );
      }),
    );
  }
}
