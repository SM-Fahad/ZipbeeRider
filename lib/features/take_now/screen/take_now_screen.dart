import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:ZipBee_Driver/core/widget/bottom_price_box.dart';
import 'package:ZipBee_Driver/core/widget/locationTile.dart';
import 'package:ZipBee_Driver/core/widget/slide_take_button_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ZipBee_Driver/features/google_map/widget/google_map_widget.dart';
import 'package:ZipBee_Driver/features/home/controller/rider_card_controller.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/model/order_stop_model.dart';

import '../../../core/common/style/global_text_style.dart';
import '../controller/take_now_controller.dart';

class TakeNowScreen extends StatelessWidget {
  const TakeNowScreen({super.key});

  Color _appBarBackgroundColor(OrderModel? order) {
    if (order == null) {
      return AppColors.primaryButtonColor;
    }

    return OrderColorHelper.getOrderBackgroundColor(
      collectTime: order.collectTime,
      scheduledTime: order.scheduledTime,
      placedAt: order.placedAt,
      defaultColor: AppColors.primaryButtonColor,
      order: order,
    );
  }

  List<OrderStopModel> _sortedStops(OrderModel order) {
    final stops = [...order.orderStops];
    stops.sort((a, b) => a.sequence.compareTo(b.sequence));
    return stops;
  }

  List<OrderStopModel> _pickupStops(OrderModel order) {
    return _sortedStops(order).where((stop) => stop.isPickup).toList();
  }

  List<OrderStopModel> _dropStops(OrderModel order) {
    return _sortedStops(order).where((stop) => stop.isDrop).toList();
  }

  String _subtitleForStop(OrderStopModel stop) {
    final shortName = stop.shortName.trim();
    if (shortName.isNotEmpty) {
      return shortName;
    }

    return stop.address;
  }

  String _remarksForOrder(OrderModel order) {
    for (final stop in _sortedStops(order)) {
      final note = stop.notes?.trim();
      if (note != null && note.isNotEmpty) {
        return note;
      }

      final additionalInfo = stop.additionalInfo?.trim();
      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        return additionalInfo;
      }
    }

    return 'No remarks';
  }

  String _formatTotalDistance(OrderModel order) {
    final distance = order.effectiveDistanceKm;
    return '${distance.toStringAsFixed(2)} km';
  }

  String? _formatStopDistance(OrderStopModel stop) {
    final distance = stop.calculatedDistanceDouble;
    if (distance <= 0) {
      return null;
    }

    final formattedDistance = distance == distance.roundToDouble()
        ? distance.toStringAsFixed(0)
        : distance.toStringAsFixed(
            distance * 10 == (distance * 10).roundToDouble() ? 1 : 2,
          );

    return '$formattedDistance km';
  }

  String? _formatStopTime(OrderStopModel stop) {
    final timeText = stop.calculatedTimeTxt?.trim();
    if (timeText == null || timeText.isEmpty) {
      return null;
    }

    return timeText;
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ controller should come from binding
    final TakeNowController ctrl = Get.put(TakeNowController());
    final RiderCardController deliveryTypeCtrl = Get.put(
      RiderCardController(),
      tag: 'take_now_delivery_type',
    );

    final width = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final order = ctrl.orderDetail.value;

          return AppBar(
            backgroundColor: _appBarBackgroundColor(order),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: Get.back,
            ),
            centerTitle: true,
            title: () {
              if (order == null) {
                return const Text('Loading...');
              }

              if (deliveryTypeCtrl.deliveryTypeName.value == null) {
                deliveryTypeCtrl.fetchDeliveryTypeName(
                  order.deliveryTypeId,
                  order.deliveryType,
                );
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      order.routeType == 'ROUND'
                          ? IconPath.roundtrip
                          : order.routeType == 'ONE_WAY'
                          ? IconPath.oneway
                          : IconPath.exparess,
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            order.vehicle.vehicleType,
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Builder(
                          //   builder: (context) {
                          //     final iconPath =
                          //         deliveryTypeCtrl.deliveryTypeIconPath.value ??
                          //         order.deliveryTypeIconPath;
                          //     if (iconPath == null)
                          //       return const SizedBox.shrink();
                          //     return Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         const SizedBox(width: 6),
                          //         Image.asset(
                          //           iconPath,
                          //           width: 18,
                          //           height: 18,
                          //           errorBuilder:
                          //               (context, error, stackTrace) =>
                          //                   const SizedBox.shrink(),
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            deliveryTypeCtrl.deliveryTypeName.value ??
                                order.deliveryType,
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Dynamic Icons.
                          Builder(
                            builder: (context) {
                              final iconPath =
                                  deliveryTypeCtrl.deliveryTypeIconPath.value ??
                                  order.deliveryTypeIconPath;
                              if (iconPath == null)
                                return const SizedBox(width: 10);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 6),
                                  Image.asset(
                                    iconPath,
                                    width: 18,
                                    height: 18,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }(),
          );
        }),
      ),

      // ================= BODY =================
      body: Obx(() {
        if (ctrl.isLoadingOrder.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.errorMessage.isNotEmpty) {
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

        // Get destinations from orderStops
        final pickupStops = _pickupStops(order);
        final dropStops = _dropStops(order);
        final remarks = _remarksForOrder(order);
        final isRoundTrip = order.routeType.toUpperCase() == 'ROUND';

        return Stack(
          children: [
            // ================= SCROLLABLE CONTENT =================
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...pickupStops.map(
                      (stop) => LocationTile(
                        title: '',
                        subtitle: _subtitleForStop(stop),
                        distance: ctrl.getPickupDistanceAndTime(),
                        trailingTopText: _formatStopDistance(stop),
                        trailingBottomText: _formatStopTime(stop),
                        isPickup: true,
                        pickupIconPath: IconPath.location_blue,
                        dropoffIconPath: IconPath.location_red,
                      ),
                    ),

                    ...dropStops.map(
                      (stop) => LocationTile(
                        title: '',
                        subtitle: _subtitleForStop(stop),
                        distance: ctrl.getDeliveryDistanceAndTime(),
                        trailingTopText: _formatStopDistance(stop),
                        trailingBottomText: _formatStopTime(stop),
                        isPickup: false,
                        pickupIconPath: IconPath.location_blue,
                        dropoffIconPath: IconPath.location_red,
                      ),
                    ),

                    if (isRoundTrip && pickupStops.isNotEmpty)
                      LocationTile(
                        title: '',
                        subtitle: _subtitleForStop(pickupStops.first),
                        distance: ctrl.getDeliveryDistanceAndTime(),
                        trailingTopText: _formatStopDistance(pickupStops.first),
                        trailingBottomText: _formatStopTime(pickupStops.first),
                        isPickup: true,
                        pickupIconPath: IconPath.location_blue,
                        dropoffIconPath: IconPath.location_red,
                      ),

                    const SizedBox(height: 20),

                    // ---------- REMARKS ----------
                    Text(
                      "Remarks:",
                      style: getTextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      remarks,
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------- PRICE ----------
                    BottomPriceBox(
                      distance: _formatTotalDistance(order),
                      price: '\$${order.riderEarningDouble.toStringAsFixed(2)}',
                      vehicleType: order.vehicle.vehicleType,
                      totalCost:
                          '\$${order.totalCostDouble.toStringAsFixed(2)}',
                      additionalCost: order.additionalCostDouble != null
                          ? '\$${order.additionalCostDouble!.toStringAsFixed(2)}'
                          : null,
                      additionalServiceFee:
                          order.additionalServiceFeeDouble != null &&
                              order.additionalServiceFeeDouble! > 0
                          ? '\$${order.additionalServiceFeeDouble!.toStringAsFixed(2)}'
                          : null,
                      routeType: order.routeType,
                    ),

                    const SizedBox(height: 26),

                    // ---------- SLIDE ----------
                    SlideToTakeButtonWidget(
                      ctrl: ctrl,
                      width: width,
                      firstColor: AppColors.primaryButtonColor,
                      secondColor: AppColors.seconderyButtonColor,
                      collectTime: order.collectTime,
                      scheduledTime: order.scheduledTime,
                      placedAt: order.placedAt,
                      order: order,
                    ),

                    const SizedBox(height: 280),
                  ],
                ),
              ),
            ),

            // ================= MAP BOTTOM SHEET =================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Obx(() {
                final sortedStopsList = _sortedStops(order);
                final routeStops = sortedStopsList
                    .map(
                      (stop) => OneMapRouteStop(
                        latitude: stop.latitude,
                        longitude: stop.longitude,
                        address: stop.address,
                        stopType: stop.isPickup ? 'PICKUP' : 'DROP',
                        sequence: stop.sequence,
                      ),
                    )
                    .toList();

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: ctrl.sheetHeight.value,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: (d) =>
                            ctrl.onDragUpdate(d.delta.dy),
                        onVerticalDragEnd: (_) => ctrl.onDragEnd(),
                        child: Container(
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: routeStops.isNotEmpty
                            ? GoogleMapWidget(
                                key: ValueKey(
                                  'take_now_google_map_${order.id}_${routeStops.length}',
                                ),
                                mode: GoogleMapWidgetMode.display,
                                initialFocus: LatLng(
                                  routeStops.first.latitude,
                                  routeStops.first.longitude,
                                ),
                                routeStops: routeStops,
                                showZoomButtons: false,
                              )
                            : const Center(
                                child: Text('No locations available'),
                              ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
