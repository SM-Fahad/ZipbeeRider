import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/model/order_stop_model.dart';
import 'package:ZipBee_Driver/features/order_progress/screen/order_process_screen.dart';
import 'package:ZipBee_Driver/features/order_details/controller/order_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  Color _appBarBackgroundColor(OrderModel? order) {
    if (order == null) {
      return AppColors.primaryButtonColor;
    }

    final isCompleted = order.isCompleted || order.orderStatus.toUpperCase() == 'COMPLETED';
    if (isCompleted) {
      return Colors.grey.shade100;
    }

    return OrderColorHelper.getOrderBackgroundColor(
      collectTime: order.collectTime,
      scheduledTime: order.scheduledTime,
      placedAt: order.placedAt,
      defaultColor: AppColors.primaryButtonColor,
      order: order,
    );
  }

  void _handleAppBarBack(OrderDetailsController ctrl) {
    if (ctrl.openedFromTakeNow) {
      var popCount = 0;
      Get.until((route) => popCount++ == 2);
      return;
    }
    if (ctrl.openedFromOngoing) {
      Get.until((route) =>
          route.settings.name?.contains('OnGoingScreen') == true ||
          route.isFirst);
      return;
    }

    Get.back();
  }

  Future<void> _launchStopCall(String phoneNumber) async {
    final trimmedPhone = phoneNumber.trim();
    if (trimmedPhone.isEmpty) {
      return;
    }

    final uri = Uri(scheme: 'tel', path: trimmedPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Call unavailable', 'Could not open phone app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailsController>(
      init: OrderDetailsController(),
      builder: (ctrl) {
        ctrl.subscribeRoute(context);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          appBar: AppBar(
            backgroundColor: _appBarBackgroundColor(ctrl.orderDetail.value),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => _handleAppBarBack(ctrl),
            ),
            title: Text(
              'Order Details',
              style: getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          body: Obx(() {
            if (ctrl.isLoadingOrder.value && ctrl.orderDetail.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ctrl.errorMessage.isNotEmpty && ctrl.orderDetail.value == null) {
              return Center(
                child: Text(
                  ctrl.errorMessage.value,
                  style: getTextStyle(color: Colors.red),
                ),
              );
            }

            final order = ctrl.orderDetail.value;
            if (order == null) {
              return const Center(child: Text('No order details'));
            }

            final stops = ctrl.sortedStops(order);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(order, ctrl),
                  const SizedBox(height: 12),
                  _buildSummaryCard(order, ctrl),
                  const SizedBox(height: 12),
                  Text(
                    'Stops',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...stops.map((stop) => _buildStopCard(stop, ctrl)),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeaderCard(OrderModel order, OrderDetailsController ctrl) {
    final statusColor = ctrl.orderStatusColor(order);
    final statusBackgroundColor = ctrl.orderStatusBackgroundColor(order);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Order #${order.id}',
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ctrl.orderStatusLabel(order),
              style: getTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(OrderModel order, OrderDetailsController ctrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _appBarBackgroundColor(order)),
      ),
      child: Column(
        children: [
          _buildCompactRow(
            'Delivery Type',
            ctrl.formatValue(order.deliveryType),
            'Vehicle Type',
            order.vehicle.vehicleName.isNotEmpty
                ? order.vehicle.vehicleName
                : order.vehicle.vehicleType,
            ctrl,
            leftIconPath: order.deliveryTypeIconPath,
          ),
          const SizedBox(height: 10),
          _buildCompactRow(
            'Route Type',
            ctrl.formatValue(order.routeType),
            'Collect Time',
            ctrl.collectTimeText(order),
            ctrl,
          ),
          const SizedBox(height: 10),
          _buildCompactRow(
            'Pay Type',
            ctrl.formatPayType(order.payType),
            'Total Rider Earning',
            '\$${order.riderEarningDouble.toStringAsFixed(2)}',
            ctrl,
          ),
          const SizedBox(height: 10),
          _buildCompactRow(
            'Total Distance',
            ctrl.getTotalDistanceText(order),
            'Order Total Cost',
            ctrl.formatAmount(order.totalCost),
            ctrl,
          ),
          if (order.additionalCostDouble != null &&
              order.additionalCostDouble! > 0) ...[
            const SizedBox(height: 10),
            _buildCompactRow(
              'Additional Cost',
              ctrl.formatAmount(order.additionalCost!),
              'Additional Service Fee',
              order.additionalServiceFeeDouble != null &&
                      order.additionalServiceFeeDouble! > 0
                  ? '\$${order.additionalServiceFeeDouble!.toStringAsFixed(2)}'
                  : 'N/A',
              ctrl,
            ),
          ] else if (order.additionalServiceFeeDouble != null &&
              order.additionalServiceFeeDouble! > 0) ...[
            const SizedBox(height: 10),
            _buildCompactRow(
              'Additional Service Fee',
              '\$${order.additionalServiceFeeDouble!.toStringAsFixed(2)}',
              '',
              '',
              ctrl,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopCard(OrderStopModel stop, OrderDetailsController ctrl) {
    final payment = stop.payment;
    final statusColor = ctrl.statusColor(stop);
    final statusBackgroundColor = ctrl.statusBackgroundColor(stop);
    final actionText = ctrl.actionButtonText(stop);
    final isCompleted = ctrl.isStopCompleted(stop);
    final hiddenValue = isCompleted ? '******' : null;
    final canCallStop =
        actionText != null && stop.destinationContactNumber.trim().isNotEmpty;
    final orderColor = _appBarBackgroundColor(ctrl.orderDetail.value);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: orderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stop.isPickup
                      ? 'Pickup ${stop.sequence}'
                      : 'Drop ${stop.sequence}',
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              // if (canCallStop) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () =>
                      _launchStopCall(stop.destinationContactNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orderColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.call, size: 16),
                  label: Text(
                    'Call',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              // ],
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ctrl.statusLabel(stop),
                  style: getTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoLine('Contact', hiddenValue ?? ctrl.titleForStop(stop)),
          const SizedBox(height: 6),
          _buildInfoLine('Address', ctrl.addressForStop(stop)),
          if (isCompleted || stop.destinationFloorUnit.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoLine(
              'Floor/Unit',
              hiddenValue ?? stop.destinationFloorUnit,
            ),
          ],
          if (stop.completedAt != null) ...[
            const SizedBox(height: 6),
            _buildInfoLine(
              'Completed At',
              ctrl.formatDateTime(stop.completedAt!),
            ),
          ],
          const SizedBox(height: 6),
          _buildInfoLine(
            'Note to Driver',
            (stop.destinationNoteToDriver?.trim().isNotEmpty ?? false)
                ? stop.destinationNoteToDriver!.trim()
                : 'N/A',
          ),
          if (payment != null) ...[
            const SizedBox(height: 10),
          ],
          if (actionText != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final order = ctrl.orderDetail.value;
                  if (order == null) {
                    return;
                  }

                  Get.to(
                    () => OrderProcessScreen(),
                    arguments: {
                      'order': order,
                      'stop': stop,
                      'stopData': stop.toJson(),
                    },
                  )?.then((_) {
                    ctrl.refreshOrderDetail();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orderColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  actionText,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactRow(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
    OrderDetailsController ctrl, {
    String? leftIconPath,
    String? rightIconPath,
  }) {
    return Row(
      children: [
        Expanded(child: _buildMiniInfo(leftLabel, leftValue, iconPath: leftIconPath)),
        if (rightLabel.isNotEmpty || rightValue.isNotEmpty) ...[
          const SizedBox(width: 12),
          Expanded(child: _buildMiniInfo(rightLabel, rightValue, iconPath: rightIconPath)),
        ],
      ],
    );
  }

  Widget _buildMiniInfo(String label, String value, {String? iconPath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            if (iconPath != null) ...[
              const SizedBox(width: 4),
              Image.asset(
                iconPath,
                width: 14,
                height: 14,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: getTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
