// Unused file now
import 'dart:io';
import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/records/on_going/on_going_customer_review/controller/complete_order_controller.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CompleteOrderScreen extends StatelessWidget {
  final controller = Get.put(CompleteOrderController());

  CompleteOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double maxDrag = width - 130;
    double leftGap = 12;
    debugPrint("order user id: ${controller.orderDetail.value?.userId}");

    void animateBack(CompleteOrderController ctrl, double maxDrag) {
      Future.microtask(() async {
        while (ctrl.dragX.value > 0) {
          await Future.delayed(const Duration(milliseconds: 5));
          ctrl.dragX.value -= 8;
          if (ctrl.dragX.value < 0) ctrl.dragX.value = 0;
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.onboardingIndicatorActive,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: Get.back,
        ),
        centerTitle: true,
        title: Text(
          "Complete Order",
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          // MAP AREA
          Positioned.fill(
            child: Obx(() {
              if (controller.pickupLocation.value == null ||
                  controller.dropoffLocation.value == null) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return GoogleMap(
                mapType: MapType.normal,
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: controller.pickupLocation.value!,
                  zoom: 14,
                ),
                markers: controller.markers.toSet(),
                polylines: controller.polylines.toSet(),
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                zoomGesturesEnabled: true,
              );
            }),
          ),

          // DRAGGABLE SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.20,
            maxChildSize: 0.80,
            builder: (context, scrollController) {
              return Obx(() {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
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
                        SizedBox(height: 18),

                        // CUSTOMER INFO SECTION
                        if (controller.isLoadingCustomer.value)
                          Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (controller.customerInfo.value != null)
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  // color: Colors.blue.shade50,
                                  // borderRadius: BorderRadius.circular(12),
                                  // border: Border.all(color: Colors.blue.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Customer Image
                                    Container(
                                      width: 76,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[300],
                                        image:
                                            controller
                                                    .customerInfo
                                                    .value
                                                    ?.image !=
                                                null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  controller
                                                      .customerInfo
                                                      .value!
                                                      .image!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child:
                                          controller
                                                  .customerInfo
                                                  .value
                                                  ?.image ==
                                              null
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.grey[600],
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 12),
                                    // Customer Info
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          controller
                                                  .customerInfo
                                                  .value
                                                  ?.username ??
                                              '',
                                          style: getTextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          controller
                                                  .customerInfo
                                                  .value
                                                  ?.phone ??
                                              '',
                                          style: getTextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 8),

                                    // Message Button
                                  ],
                                ),
                              ),
                              SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      final userId =
                                          controller.orderDetail.value?.userId;
                                      final customerName =
                                          controller
                                              .customerInfo
                                              .value
                                              ?.username ??
                                          'Customer';
                                      final orderId =
                                          controller.orderDetail.value?.id;
                                      final total =
                                          controller
                                              .orderDetail
                                              .value
                                              ?.totalCost ??
                                          '0';
                                      final assignRiderPhone =
                                          controller
                                              .customerInfo
                                              .value
                                              ?.phone ??
                                          '';
                                      //  final veycaleType = controller.orderDetail.value?.vehicle?.type ?? 'Unknown';
                                      // Convert to String if not null

                                      if (userId != null) {
                                        final vehicleType = controller.orderDetail.value?.vehicle.vehicleType ?? 'UNKNOWN';
                                        // Pass receiverId via navigation arguments
                                        Get.toNamed(
                                          AppRoutes.getRiderChatScreen(),
                                          arguments: {
                                            'receiverId': userId,
                                            'customerName': customerName,
                                            'orderId': orderId,
                                            'total': total,
                                            'assignRiderPhone':
                                                assignRiderPhone,
                                            'vehicleType': vehicleType,
                                          },
                                        );
                                      } else {
                                        EasyLoading.showError(
                                          'Customer ID not available',
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 124,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(color: Colors.black),
                                        //color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(
                                            Icons.message,
                                            color: Colors.black,
                                            size: 20,
                                          ),

                                          Text(
                                            'Message',
                                            style: getTextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // Call Button
                                  GestureDetector(
                                    onTap: () => _launchCall(
                                      controller.customerInfo.value?.phone ??
                                          '',
                                    ),
                                    child: Container(
                                      width: 124,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          Text(
                                            'Call',
                                            style: getTextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // STOP PROGRESS
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: controller.currentStopType.value == 'PICKUP'
                                ? Colors.blue.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  controller.currentStopType.value == 'PICKUP'
                                  ? Colors.blue.shade300
                                  : Colors.orange.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current: ${controller.currentStopType.value}',
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          controller.currentStopType.value ==
                                              'PICKUP'
                                          ? Colors.blue.shade700
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                  Text(
                                    '${controller.completedStops.length + 1}/${controller.completedStops.length + controller.remainingStops.length}',
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
                        ),

                        SizedBox(height: 18),

                        // CURRENT LOCATION
                        Container(
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
                                '${controller.currentStopType.value} Location',
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          controller.currentStopType.value ==
                                              'PICKUP'
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      controller.currentStopAddress.value,
                                      style: getTextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // DELIVERY NOTES
                        Text(
                          'Delivery Notes (Optional)',
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Enter delivery notes...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),

                        SizedBox(height: 20),

                        // COD AMOUNT
                        if (controller.codAmount.value > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COD Amount',
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Amount to Collect:',
                                      style: getTextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\$${controller.codAmount.value.toStringAsFixed(2)}',
                                      style: getTextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),

                        // PROOF PHOTOS SECTION
                        Text(
                          'Proof Photos',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Photo grid
                        if (controller.selectedImages.isNotEmpty)
                          Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                itemCount: controller.selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          image: DecorationImage(
                                            image: FileImage(
                                              File(
                                                controller
                                                    .selectedImages[index],
                                              ),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () =>
                                              controller.removeImage(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 20),
                            ],
                          ),

                        // ERROR MESSAGE
                        if (controller.errorMessage.isNotEmpty)
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                child: Text(
                                  controller.errorMessage.value,
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),

                        // SLIDE BUTTONS
                        // If no photos taken yet, show "Take Photos" slider
                        if (controller.selectedImages.isEmpty)
                          _buildSlideButton(
                            width: width,
                            maxDrag: maxDrag,
                            leftGap: leftGap,
                            animateBack: animateBack,
                            buttonText: "Take photo's",
                            onSlideEnd: () async {
                              await controller.openCamera();
                              await controller.openGallery();
                            },
                          )
                        else
                          // If photos are taken, show "Complete Order" slider
                          _buildSlideButton(
                            width: width,
                            maxDrag: maxDrag,
                            leftGap: leftGap,
                            animateBack: animateBack,
                            buttonText: "Complete Order",
                            onSlideEnd: () async {
                              if (!controller.isUploading.value &&
                                  !controller.isCompleting.value) {
                                await controller.completeCurrentStop();
                              }
                            },
                          ),

                        SizedBox(height: 30),
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

  Widget _buildSlideButton({
    required double width,
    required double maxDrag,
    required double leftGap,
    required Function animateBack,
    required String buttonText,
    required Function onSlideEnd,
  }) {
    return Obx(() {
      double progress = (controller.dragX.value / maxDrag).clamp(0.0, 1.0);

      Color backgroundColor = Color.lerp(
        AppColors.onboardingIndicatorActive,
        Colors.blue.shade200,
        progress,
      )!;

      double textOpacity = 1.0 - progress;

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

          // Text
          Opacity(
            opacity: textOpacity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 54),
                      Text(
                        buttonText,
                        style: getTextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Slider Button
          Positioned(
            left: controller.dragX.value + leftGap,
            top: 12,
            bottom: 12,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                controller.dragX.value += details.delta.dx;

                if (controller.dragX.value < 0) controller.dragX.value = 0;
                if (controller.dragX.value > maxDrag)
                  controller.dragX.value = maxDrag;
              },
              onHorizontalDragEnd: (details) async {
                if (controller.dragX.value >= maxDrag - 5) {
                  await onSlideEnd();

                  // Reset slider
                  Future.delayed(
                    Duration(milliseconds: 300),
                    () => controller.dragX.value = 0,
                  );
                } else {
                  // Animate back if not fully slid
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
                  child:
                      controller.isUploading.value ||
                          controller.isCompleting.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.arrow_forward, size: 24),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Launch SMS to customer
  // void _launchSMS(String phoneNumber) async {
  //   try {
  //     final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
  //     if (await canLaunchUrl(smsUri)) {
  //       await launchUrl(smsUri);
  //     } else {
  //       Get.snackbar(
  //         'Error',
  //         'Could not launch SMS',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to open SMS: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  /// Launch call to customer
  void _launchCall(String phoneNumber) async {
    try {
      final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        EasyLoading.showError('Could not launch phone call');
      }
    } catch (e) {
      EasyLoading.showError('Failed to open phone call: $e');
    }
  }
}
