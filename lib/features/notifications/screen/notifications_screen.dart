import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/notifications/controller/notifications_controller.dart';
import 'package:ZipBee_Driver/features/notifications/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Notifications',
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Obx(
          () => Column(
            children: [
              // ---- Tabs ----
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(controller.tabs.length, (index) {
                    final isSelected =
                        controller.selectedTabIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.changeTab(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                          color: isSelected
                              ? AppColors.primaryButtonColor
                              : Colors.transparent,
                        ),
                        child: Text(
                          controller.tabs[index],
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // ---- List ----
              Expanded(
                child: controller.isLoading.value &&
                        controller.notificationList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : controller.notificationList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No ${controller.tabs[controller.selectedTabIndex.value]} Found',
                                  style: getTextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                controller.fetchNotifications(),
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (scrollInfo) {
                                if (!controller.isLoading.value &&
                                    scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent -
                                            80) {
                                  controller.fetchNotifications(
                                      loadMore: true);
                                }
                                return false;
                              },
                              child: ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    controller.notificationList.length +
                                        (controller.isLoading.value &&
                                                controller
                                                    .notificationList
                                                    .isNotEmpty
                                            ? 1
                                            : 0),
                                itemBuilder: (_, index) {
                                  if (index >=
                                      controller.notificationList.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  final item =
                                      controller.notificationList[index];
                                  return _NotificationCard(
                                    item: item,
                                    controller: controller,
                                  );
                                },
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final NotificationsController controller;

  const _NotificationCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isRead = item.isRead;
    final cardColor = isRead ? const Color(0xFFF3F3F3) : Colors.white;
    final borderColor =
        isRead ? Colors.transparent : AppColors.primaryButtonColor;
    final titleColor = isRead ? Colors.grey.shade600 : Colors.black87;
    final subtitleColor = isRead ? Colors.grey : const Color(0xFF6B6B6B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.delete_forever_outlined,
            size: 32,
            color: Colors.red,
          ),
        ),
        confirmDismiss: (_) async {
          bool confirmed = false;
          await Get.defaultDialog(
            title: "Delete Notification",
            middleText:
                "Are you sure you want to delete this notification?",
            textConfirm: "Yes",
            textCancel: "No",
            confirmTextColor: Colors.white,
            buttonColor: Colors.red,
            onConfirm: () {
              confirmed = true;
              Get.back();
            },
            onCancel: () => confirmed = false,
          );
          if (!confirmed) return false;
          final success = await controller.deleteNotification(item.id);
          return success;
        },
        onDismissed: (_) {},
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => controller.onNotificationTap(item),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(
                color: borderColor,
                width: isRead ? 0 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: isRead
                          ? Colors.grey
                          : AppColors.primaryButtonColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: getTextStyle(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.date,
                      style: getTextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    Text(
                      item.time,
                      style: getTextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
