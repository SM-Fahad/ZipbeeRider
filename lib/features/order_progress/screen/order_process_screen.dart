import 'dart:io';

import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/home/model/order_stop_model.dart';
import 'package:ZipBee_Driver/features/order_progress/controller/order_process_controller.dart';
import 'package:ZipBee_Driver/features/scan_and_pay/screen/scan_and_pay_screen.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderProcessScreen extends StatelessWidget {
  OrderProcessScreen({super.key});

  final OrderProcessController controller = Get.put(OrderProcessController());

  Color _getOrderColor(OrderModel? order) {
    if (order == null) {
      return AppColors.onboardingIndicatorActive;
    }

    final isCompleted =
        order.isCompleted || order.orderStatus.toUpperCase() == 'COMPLETED';
    if (isCompleted) {
      return Colors.grey.shade100;
    }

    return OrderColorHelper.getOrderBackgroundColor(
      collectTime: order.collectTime,
      scheduledTime: order.scheduledTime,
      placedAt: order.placedAt,
      defaultColor: AppColors.onboardingIndicatorActive,
      order: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double maxDrag = width - 130;
    final double leftGap = 12;

    void animateBack(OrderProcessController ctrl, double maxDrag) {
      Future.microtask(() async {
        while (ctrl.dragX.value > 0) {
          await Future.delayed(const Duration(milliseconds: 5));
          ctrl.dragX.value -= 8;
          if (ctrl.dragX.value < 0) {
            ctrl.dragX.value = 0;
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => AppBar(
            backgroundColor: _getOrderColor(controller.orderDetail.value),
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: Get.back,
            ),
            centerTitle: true,
            title: Text(
              controller.appBarTitle,
              style: getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final markerSet = controller.markers.toSet();
              final polylineSet = controller.polylines.toSet();
              final hasCurrentLocation =
                  controller.currentLocation.value != null;

              if (controller.orderDetail.value == null) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              return GoogleMap(
                mapType: MapType.normal,
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: controller.initialCameraPosition.value,
                markers: markerSet,
                polylines: polylineSet,
                myLocationEnabled: hasCurrentLocation,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                zoomGesturesEnabled: true,
              );
            }),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.20,
            maxChildSize: 0.80,
            builder: (context, scrollController) {
              return Obx(() {
                final order = controller.orderDetail.value;
                if (order == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            height: 5,
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildCustomerSection(),
                        const SizedBox(height: 18),
                        _buildOrderConfirmationSection(),
                        const SizedBox(height: 18),
                        _buildSummaryCard(order.id),
                        const SizedBox(height: 18),
                        _buildStopProgressSection(),
                        const SizedBox(height: 18),
                        _buildCurrentLocationSection(),
                        const SizedBox(height: 20),
                        _buildDeliveryNotesSection(),
                        const SizedBox(height: 20),
                        if (controller.isCurrentStopUnpaid) ...[
                          _buildCodAmountSection(),
                          const SizedBox(height: 20),
                        ],
                        _buildProofPhotosSection(),
                        const SizedBox(height: 20),
                        if (controller.errorMessage.isNotEmpty) ...[
                          _buildErrorSection(),
                          const SizedBox(height: 20),
                        ],
                        const SizedBox(height: 8),
                        _buildSlideButton(
                          width: width,
                          maxDrag: maxDrag,
                          leftGap: leftGap,
                          animateBack: animateBack,
                          buttonText: controller.slideButtonText,
                          onSlideEnd: controller.handleSlideAction,
                        ),
                        // Don't remove commented code 
                        // const SizedBox(height: 12),
                        // _buildActionButtonsRow(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: controller.customerImage != null
                      ? DecorationImage(
                          image: NetworkImage(controller.customerImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.customerImage == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    controller.customerName,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.customerPhone,
                    style: getTextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () async {
                final userId = controller.orderDetail.value?.userId;
                final customerName = controller.customerName.isNotEmpty
                    ? controller.customerName
                    : 'Customer';
                final orderId = controller.orderDetail.value?.id;
                final total = controller.orderDetail.value?.totalCost ?? '0';
                final assignRiderPhone = controller.customerPhone;

                if (userId != null) {
                  final vehicleType = controller.orderDetail.value?.vehicle.vehicleType ?? 'UNKNOWN';
                  Get.toNamed(
                    AppRoutes.getRiderChatScreen(),
                    arguments: {
                      'receiverId': userId,
                      'customerName': customerName,
                      'orderId': orderId,
                      'total': total,
                      'assignRiderPhone': assignRiderPhone,
                      'vehicleType': vehicleType,
                    },
                  );
                } else {
                  EasyLoading.showError('Customer ID not available');
                }
              },
              child: _buildActionBox(Icons.message, 'Message'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                _launchCall(controller.customerPhone);
              },
              child: _buildActionBox(Icons.call, 'Call'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderConfirmationSection() {
    return Obx(
      () {
        final order = controller.orderDetail.value;
        final showConfirmation = order != null &&
            (order.raiderConfirmation || order.isAutoConfirmation);

        return Row(
          children: [
            if (showConfirmation)
              GestureDetector(
                onTap: () {
                  controller.checkCustomerConfirmation();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: controller.orderConfirmationStatusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.orderConfirmationStatusText,
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (controller.canChangeRoute) const Spacer(),
            if (controller.canChangeRoute)
              GestureDetector(
                onTap: controller.isReorderingRoute.value
                    ? null
                    : _showChangeRouteDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: controller.isReorderingRoute.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Change Route',
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showChangeRouteDialog() async {
    final order = controller.orderDetail.value;
    if (order == null) {
      return;
    }

    final pickupStops = controller.sortedStops
        .where((stop) => stop.isPickup)
        .toList();
    final pickupStop = pickupStops.firstOrNull;
    final dropStops = controller.sortedStops
        .where((stop) => stop.isDrop)
        .toList();
    if (dropStops.length < 2) {
      return;
    }

    final workingDrops = List<OrderStopModel>.from(dropStops);

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Route',
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (pickupStop != null) ...[
                    _buildRouteStopTile(
                      label: 'Pick up',
                      address: pickupStop.address,
                      sequence: pickupStop.sequence,
                      isDraggable: false,
                    ),
                    const SizedBox(height: 10),
                  ],
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      itemCount: workingDrops.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          final item = workingDrops.removeAt(oldIndex);
                          workingDrops.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final stop = workingDrops[index];
                        return Padding(
                          key: ValueKey(stop.id),
                          padding: EdgeInsets.only(
                            bottom: index == workingDrops.length - 1 ? 0 : 10,
                          ),
                          child: _buildRouteStopTile(
                            label: 'Drop',
                            address: stop.address,
                            sequence: index + 1,
                            isDraggable: true,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isReorderingRoute.value
                            ? null
                            : () async {
                                await controller.reorderDropStops(
                                  List<OrderStopModel>.from(workingDrops),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _getOrderColor(controller.orderDetail.value),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: controller.isReorderingRoute.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'Save Change',
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteStopTile({
    required String label,
    required String address,
    required int sequence,
    required bool isDraggable,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label : $sequence',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: getTextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isDraggable) ...[
            const SizedBox(width: 10),
            ReorderableDragStartListener(
              index: sequence - 1,
              child: const Icon(Icons.drag_handle, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBox(IconData icon, String title) {
    return Container(
      width: 124,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(icon, color: Colors.black, size: 20),
          Text(
            title,
            style: getTextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopProgressSection() {
    final bool isPickup = controller.currentStopType == 'PICKUP';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPickup ? Colors.blue.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPickup ? Colors.blue.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current: ${controller.currentStopType}',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isPickup
                      ? Colors.blue.shade700
                      : Colors.orange.shade700,
                ),
              ),
              Text(
                '${controller.currentStopNumber}/${controller.sortedStops.length}',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (controller.completedStops.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Completed: ${controller.completedStops.length} stops',
                style: getTextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationSection() {
    final stop = controller.selectedStop.value;
    if (stop == null) {
      return const SizedBox.shrink();
    }

    final payment = stop.payment;
    final statusColor = controller.statusColor(stop);
    final statusBackgroundColor = controller.statusBackgroundColor(stop);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${controller.currentStopType} Location',
            style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  stop.isPickup
                      ? 'Pickup ${stop.sequence} (ID: ${stop.id})'
                      : 'Drop ${stop.sequence} (ID: ${stop.id})',
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
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
                  controller.statusText(stop),
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
          _buildInfoLine('Contact', controller.stopTitle(stop)),
          const SizedBox(height: 6),
          _buildInfoLine(
            'Phone',
            stop.destinationContactNumber.isNotEmpty
                ? stop.destinationContactNumber
                : 'N/A',
          ),
          const SizedBox(height: 6),
          _buildInfoLine('Address', stop.address),
          if (stop.destinationFloorUnit.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoLine('Floor/Unit', stop.destinationFloorUnit),
          ],
          const SizedBox(height: 6),
          _buildInfoLine(
            'Note to Driver',
            (stop.destinationNoteToDriver?.trim().isNotEmpty ?? false)
                ? stop.destinationNoteToDriver!.trim()
                : 'N/A',
          ),
          if (controller.latestActionLabel != null &&
              controller.latestActionValue != null) ...[
            const SizedBox(height: 6),
            _buildInfoLine(
              controller.latestActionLabel!,
              controller.latestActionValue!,
            ),
          ],
          if (payment != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _buildCompactRow(
              'Pay Type',
              payment.payType.replaceAll('_', ' '),
              'Amount',
              '\$${payment.amount}',
            ),
            const SizedBox(height: 10),
            _buildCompactRow(
              'Pay Status',
              payment.status.replaceAll('_', ' '),
              'Discount',
              '\$${payment.discount}',
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.startInAppNavigation(),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _getOrderColor(controller.orderDetail.value),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.navigation, size: 20),
              label: Text(
                'Navigate to ${stop.isPickup ? "Pickup" : "Drop"} Stop',
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Notes (Optional)',
          style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enter delivery notes...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildCodAmountSection() {
    return Obx(() {
      final shouldShowCodSection =
          controller.isCurrentStopUnpaid &&
          controller.slideButtonText == 'Complete Stop';

      if (!shouldShowCodSection) {
        return const SizedBox.shrink();
      }

      if (controller.cashCollectedController.text.isEmpty) {
        final amountText = controller.codAmount % 1 == 0
            ? controller.codAmount.toInt().toString()
            : controller.codAmount.toStringAsFixed(2);
        controller.cashCollectedController.text = amountText;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Collected Cash Amount',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.orderDetail.value == null
                    ? null
                    : () {
                        Get.to(
                          () => ScanAndPayScreen(),
                          arguments: {
                            'order': controller.orderDetail.value,
                            'orderStopId': controller.selectedStop.value?.id,
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _getOrderColor(controller.orderDetail.value),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.qr_code_2, size: 18),
                label: const Text('Scan & Pay'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.cashCollectedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter collected cash amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Expected amount: \$${controller.codAmount.toStringAsFixed(2)}',
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProofPhotosSection() {
    return Obx(() {
      final shouldShowSection =
          controller.slideButtonText == 'Take Photo' ||
          controller.slideButtonText == 'Complete Stop' ||
          controller.selectedImages.isNotEmpty;

      if (!shouldShowSection) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proof Photos',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...List.generate(controller.selectedImages.length, (index) {
                return Stack(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(
                            File(controller.selectedImages[index]),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              GestureDetector(
                onTap: controller.isUploading.value
                    ? null
                    : controller.showPhotoSourcePicker,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryButtonColor),
                    color: Colors.grey.shade100,
                  ),
                  child: controller.isUploading.value
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.add_a_photo_outlined, size: 28),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(int orderId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryButtonColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #$orderId',
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildCompactRow(
            'Order Type',
            controller.orderTypeText(),
            'Payment',
            controller.paymentTypeText(),
          ),
          const SizedBox(height: 10),
          _buildCompactRow(
            'Amount',
            controller.amountText(),
            'Stops',
            '${controller.sortedStops.length}',
          ),
        ],
      ),
    );
  }

  Widget _buildSlideButton({
    required double width,
    required double maxDrag,
    required double leftGap,
    required Function animateBack,
    required String buttonText,
    required Function onSlideEnd,
  }) {
    return Obx(() {
      final Color backgroundColor =
          _getOrderColor(controller.orderDetail.value);
      final double progress =
          maxDrag > 0 ? (controller.dragX.value / maxDrag).clamp(0.0, 1.0) : 0.0;
      final double textOpacity = (1.0 - progress).clamp(0.0, 1.0);

      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 68,
            width: width,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          SizedBox(
            height: 68,
            width: width,
            child: Center(
              child: Opacity(
                opacity: textOpacity,
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: controller.dragX.value + leftGap,
            top: 12,
            bottom: 12,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (controller.isBusy) {
                  return;
                }
                controller.dragX.value += details.delta.dx;
                if (controller.dragX.value < 0) {
                  controller.dragX.value = 0;
                }
                if (controller.dragX.value > maxDrag) {
                  controller.dragX.value = maxDrag;
                }
              },
              onHorizontalDragEnd: (details) async {
                if (controller.isBusy) {
                  animateBack(controller, maxDrag);
                  return;
                }
                if (controller.dragX.value >= maxDrag - 5) {
                  await onSlideEnd();
                  Future.delayed(
                    const Duration(milliseconds: 300),
                    controller.resetSlider,
                  );
                } else {
                  animateBack(controller, maxDrag);
                }
              },
              child: Container(
                height: 44,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: controller.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward, size: 24),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }




  Widget _buildErrorSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Text(
        controller.errorMessage.value,
        style: getTextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }

  Widget _buildCompactRow(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
  ) {
    return Row(
      children: [
        Expanded(child: _buildMiniInfo(leftLabel, leftValue)),
        const SizedBox(width: 12),
        Expanded(child: _buildMiniInfo(rightLabel, rightValue)),
      ],
    );
  }

  Widget _buildMiniInfo(String label, String value) {
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
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
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

  void _launchCall(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      Get.snackbar(
        'Call',
        'Customer phone number not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
      return;
    }

    Get.snackbar(
      'Call',
      'Could not launch phone call',
      snackPosition: SnackPosition.BOTTOM,
    );
  }


}
