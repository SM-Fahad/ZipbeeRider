import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/model/order_stop_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.defaultStatusLabel,
    this.onTap,
  });

  final OrderModel order;
  final String defaultStatusLabel;
  final VoidCallback? onTap;

  bool get _isCompletedOrCancelled {
    final status = order.orderStatus.toUpperCase();
    final defaultLabel = defaultStatusLabel.toUpperCase();
    return order.isCompleted ||
        order.isCancelled ||
        status == 'COMPLETED' ||
        status == 'CANCELLED' ||
        status == 'CANCELED' ||
        status == 'FAILED' ||
        defaultLabel == 'COMPLETED' ||
        defaultLabel == 'CANCELLED' ||
        defaultLabel == 'CANCELED' ||
        defaultLabel == 'FAILED';
  }

  String _addressForStop(OrderStopModel stop) {
    final isOrderCompleted =
        order.isCompleted ||
        order.orderStatus.toUpperCase() == 'COMPLETED' ||
        defaultStatusLabel.toUpperCase() == 'COMPLETED';
    final isStopCompletedStatus =
        _resolveStopStatusLabel(stop) == 'COMPLETED';

    if (isOrderCompleted || isStopCompletedStatus) {
      return stop.displayName;
    }

    return stop.address;
  }

  @override
  Widget build(BuildContext context) {
    final stops = [...order.orderStops]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final headerColor = _isCompletedOrCancelled
        ? Colors.grey.shade100
        : _getHeaderColor();
    final borderColor = _isCompletedOrCancelled
        ? Colors.grey.shade300
        : headerColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: headerColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            order.deliveryType.toUpperCase(),
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          if (order.deliveryTypeIconPath != null) ...[
                            const SizedBox(width: 6),
                            Image.asset(
                              order.deliveryTypeIconPath!,
                              height: 18,
                              width: 18,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                      // Don't remove this code. It's for future use.
                      const SizedBox(height: 2),
                      Text(
                        "ID #${order.id}",
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(
                      (order.collectTime.toUpperCase() == 'SCHEDULED' && order.scheduledTime != null)
                          ? order.scheduledTime!
                          : order.createdAt,
                    ),
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(stops.length, (i) {
                    final stop = stops[i];
                    return _buildTimelineItem(
                      title: _addressForStop(stop),
                      status: _resolveStopStatusLabel(stop),
                      isPickup: stop.type == 'PICKUP',
                      showLine: i != stops.length - 1,
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // if (order.deliveryTypeIconPath != null) ...[
                            //   Image.asset(
                            //     order.deliveryTypeIconPath!,
                            //     height: 18,
                            //     width: 18,
                            //     errorBuilder: (context, error, stackTrace) =>
                            //         const SizedBox.shrink(),
                            //   ),
                            //   const SizedBox(width: 6),
                            // ],
                            Image.asset(
                              IconPath.oneway,
                              height: 18,
                              width: 18,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.location_city_rounded,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "${_formatDistance(order.effectiveDistanceKm)} KM",
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 1.5, height: 15, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              IconPath.money,
                              height: 18,
                              width: 18,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.payments_outlined,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _buildPriceText(
                                  displayExtraFee,
                                  displayBasePay,
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get displayBasePay {
    return order.basePay ?? order.riderEarningDouble;
  }

  double get displayExtraFee {
    return order.extraFee ?? order.extraCostDouble;
  }

  String _formatDate(DateTime date) {
    try {
      final localDate = date.toLocal();
      return DateFormat('dd MMM, hh:mm a').format(localDate);
    } catch (_) {
      return date.toString();
    }
  }

  String _formatDistance(double distanceKm) {
    return distanceKm.toStringAsFixed(2);
  }

  String _buildPriceText(double displayExtraFee, double displayBasePay) {
    if (displayExtraFee > 0) {
      return "\$${displayExtraFee.toStringAsFixed(2)} + \$${displayBasePay.toStringAsFixed(2)}";
    }
    return "\$${displayBasePay.toStringAsFixed(2)}";
  }

  Color _getHeaderColor() {
    return OrderColorHelper.getOrderBackgroundColor(
      collectTime: order.collectTime,
      scheduledTime: order.scheduledTime,
      placedAt: order.placedAt,
      defaultColor: AppColors.primaryButtonColor,
      order: order,
    );
  }

  String _resolveStopStatusLabel(OrderStopModel stop) {
    final rawStatus = stop.status.toUpperCase();

    if (rawStatus == 'COMPLETE' || rawStatus == 'COMPLETED') {
      return 'COMPLETED';
    } else if (rawStatus == 'FAILED') {
      return 'FAILED';
    } else if (stop.isSkiped) {
      return 'SKIPED';
    } else if (stop.isPickup && stop.isLoad) {
      return 'LOADED';
    } else if (stop.isDrop && stop.isUnload) {
      return 'UNLOADED';
    } else if (stop.isArrived) {
      return 'ARRIVED';
    } else if (stop.proceedToPickup) {
      return 'PROCEED';
    }

    return defaultStatusLabel;
  }

  Widget _buildTimelineItem({
    required String title,
    String? status,
    required bool isPickup,
    required bool showLine,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPickup ? Colors.green : Colors.red,
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(width: 1.5, color: Colors.grey.shade300),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (status != null && status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: getTextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getStatusTextColor(status),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBackgroundColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETE':
      case 'COMPLETED':
        return const Color(0xFFDCFCE7);
      case 'FAILED':
        return const Color(0xFFFEE2E2);
      case 'SKIPED':
        return const Color(0xFFFEF3C7);
      case 'UNLOADED':
      case 'LOADED':
      case 'ARRIVED':
      case 'PROCEED':
        return const Color(0xFFDBEAFE);
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      case 'CANCELLED':
      case 'CANCELED':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETE':
      case 'COMPLETED':
        return const Color(0xFF22C55E);
      case 'FAILED':
      case 'CANCELLED':
      case 'CANCELED':
        return const Color(0xFFEF4444);
      case 'SKIPED':
        return const Color(0xFFF59E0B);
      case 'UNLOADED':
      case 'LOADED':
      case 'ARRIVED':
      case 'PROCEED':
        return const Color(0xFF3B82F6);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
