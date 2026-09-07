import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/home/controller/home_controller.dart';
import 'package:ZipBee_Driver/features/home/controller/rider_card_controller.dart';
import 'package:ZipBee_Driver/features/home/widgets/swipe_button_widget.dart';
import 'package:ZipBee_Driver/features/take_now/screen/take_now_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/order_model.dart';
import '../model/order_stop_model.dart';

class RiderCardWidget extends StatelessWidget {
  final OrderModel order;
  final int index;
  final HomeController ctrl;
  late final RiderCardController _cardCtrl;

  RiderCardWidget({
    super.key,
    required this.order,
    required this.index,
    required this.ctrl,
  }) {
    _cardCtrl = _findOrCreateCardController(order);
    _cardCtrl.fetchDeliveryTypeName(order.deliveryTypeId, order.deliveryType);
  }

  static RiderCardController _findOrCreateCardController(OrderModel order) {
    final tag = 'rider_card_${order.id}_${order.deliveryTypeId}';
    if (Get.isRegistered<RiderCardController>(tag: tag)) {
      return Get.find<RiderCardController>(tag: tag);
    }
    return Get.put(RiderCardController(), tag: tag);
  }

  void goToDifferentScreen(OrderModel order) {
    // Navigate to TakeNowScreen with order ID
    Get.to(
      () => TakeNowScreen(),
      arguments: order.id,
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 300),
    );
  }

  String get paymentLabel {
    if (order.payType.toUpperCase() == 'COD') {
      return 'CASH';
    }

    return order.payType;
  }

  String get totalDistanceText {
    final distance = order.effectiveDistanceKm;
    return '${distance.toStringAsFixed(1)}Km';
  }

  String get totalTimeText {
    final minutes = order.effectiveTotalTimeMinutes;
    if (minutes <= 0) return '-- Mins';
    return '$minutes Mins';
  }

  String _addressTextForStop(OrderStopModel stop) {
    final shortName = stop.shortName.trim();
    if (shortName.isNotEmpty) {
      return shortName;
    }

    final destination = stop.rawData?['destination'];
    if (destination is Map) {
      final destinationShortName = destination['shortName']?.toString().trim();
      if (destinationShortName != null && destinationShortName.isNotEmpty) {
        return destinationShortName;
      }
    }

    return stop.address;
  }

  String get pickupAddressText {
    try {
      final pickup = order.orderStops.firstWhere((stop) => stop.isPickup);
      return _addressTextForStop(pickup);
    } catch (e) {
      return 'Unknown location';
    }
  }

  List<String> get dropAddressTexts {
    return order.orderStops
        .where((stop) => stop.isDrop)
        .map(_addressTextForStop)
        .toList();
  }

  String _formatRaiderToPickupKm(double? value) {
    if (value == null) return '';
    final distStr = value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '~$distStr Km';
  }

  int get dropCount {
    return order.dropCount ??
        order.orderStops.where((stop) => stop.isDrop).length;
  }

  String get lastDropAddressText {
    final drops = order.orderStops.where((stop) => stop.isDrop).toList();
    if (drops.isEmpty) return 'Unknown location';
    return _addressTextForStop(drops.last);
  }

  bool get isRoundTrip => order.routeType.toUpperCase() == 'ROUND';

  int get displayStopsCount => dropCount > 1 ? dropCount - 1 : 0;

  String get bottomAddressText => lastDropAddressText;

  double get displayBasePay {
    return order.basePay ?? order.riderEarningDouble;
  }

  double get displayExtraFee {
    return order.extraFee ?? order.extraCostDouble;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => goToDifferentScreen(order),

      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(0xFFE3F2FD),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        order.routeType == 'ROUND'
                            ? IconPath.roundtrip
                            : order.routeType == 'ONE_WAY'
                            ? IconPath.oneway
                            : IconPath.exparess,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.local_shipping_outlined,
                              color: Colors.grey,
                              size: 24,
                            ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.raiderToPickupKm != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatRaiderToPickupKm(order.raiderToPickupKm),
                              style: getTextStyle(
                                color: const Color(0xFF856404),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Obx(() {
                          final name =
                              _cardCtrl.deliveryTypeName.value ??
                              order.deliveryType;
                          final iconPath =
                              _cardCtrl.deliveryTypeIconPath.value ??
                              order.deliveryTypeIconPath;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // Dynamic Icon
                              if (iconPath != null) ...[
                                const SizedBox(width: 6),
                                Image.asset(
                                  iconPath,
                                  width: 18,
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox.shrink(),
                                ),
                              ],
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // Cost details, distance and time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text(
                    //   'Order #${order.id}',
                    //   style: getTextStyle(
                    //     color: Colors.grey.shade600,
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    // const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayExtraFee > 0
                              ? '\$${displayExtraFee.toStringAsFixed(2)} + \$${displayBasePay.toStringAsFixed(2)}'
                              : '\$${displayBasePay.toStringAsFixed(2)}',
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          totalDistanceText,
                          style: getTextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '|',
                          style: getTextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          totalTimeText,
                          style: getTextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            IconPath.location_blue,
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pickupAddressText,
                              style: getTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 12),
                            child: Column(
                              children: List.generate(
                                2,
                                (_) => Container(
                                  width: 3,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (displayStopsCount >= 1)
                            Text(
                              displayStopsCount == 1
                                  ? '1 Stop'
                                  : '$displayStopsCount Stops',
                              style: getTextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            IconPath.location_red,
                            // isRoundTrip
                            //     ? IconPath.location_blue
                            //     : IconPath.location_red,
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bottomAddressText,
                              style: getTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            SwipeButtonWidget(
              uniqueTag: 'swipe_button_${order.id}',
              leftText: order.buttonText,
              rightText: order.rightButtonText,
              onAccept: () => ctrl.acceptOrder(index),
              onDecline: () => ctrl.declineOrder(index),
              backgroundColor: AppColors.primaryButtonColor,
              height: 50,
              iconPath: IconPath.car,
              vehicleType: order.vehicle.vehicleType,
              collectTime: order.collectTime,
              scheduledTime: order.scheduledTime,
              placedAt: order.placedAt,
              sectionColor: order.sectionColor,
              primarySectionColor: order.primarySectionColor,
              order: order,
            ),
          ],
        ),
      ),
    );
  }
}
