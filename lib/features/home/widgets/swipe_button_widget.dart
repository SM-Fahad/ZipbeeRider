import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
// import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class SwipeButtonController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animCtrl;
  late Animation<double> anim;
  final dragX = 0.0.obs;
  double maxDrag = 0.0;
  double minDrag = 0.0;

  @override
  void onInit() {
    super.onInit();
    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    animCtrl.dispose();
    super.onClose();
  }

  void onPanStart(DragStartDetails details) => animCtrl.stop();

  void onPanUpdate(DragUpdateDetails details) {
    dragX.value += details.delta.dx;
    dragX.value = dragX.value.clamp(minDrag, maxDrag);
  }

  void onPanEnd(DragEndDetails details, VoidCallback onAccept, VoidCallback onDecline) {
    if (dragX.value > maxDrag * 0.8) {
      onAccept();
      animateTo(0);
    } else if (dragX.value < minDrag * 0.8) {
      onDecline();
      animateTo(0);
    } else {
      animateTo(0);
    }
  }

  void animateTo(double to) {
    final start = dragX.value;
    anim = Tween<double>(begin: 0, end: 1).animate(animCtrl)
      ..addListener(() {
        dragX.value = start + (anim.value) * (to - start);
      });
    animCtrl
      ..reset()
      ..forward();
  }
}

class SwipeButtonWidget extends StatelessWidget {
  final String leftText;
  final String rightText;
  final Color backgroundColor;
  final double height;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String iconPath;
  final String? vehicleType;
  final String? collectTime;
  final DateTime? scheduledTime;
  final DateTime? placedAt;
  final String uniqueTag;
  final String? sectionColor;
  final String? primarySectionColor;
  final OrderModel? order;

  const SwipeButtonWidget({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.backgroundColor,
    this.height = 60,
    required this.onAccept,
    required this.onDecline,
    required this.iconPath,
    this.vehicleType,
    this.collectTime,
    this.scheduledTime,
    this.placedAt,
    required this.uniqueTag,
    this.sectionColor,
    this.primarySectionColor,
    this.order,
  });

  String _getAcceptLabel() {
    final collectTimeVal = collectTime?.toUpperCase();
    final now = DateTime.now();

    if (collectTimeVal == 'ASAP') {
      // If placedAt is in the past, show the date/time
      if (placedAt != null) {
        final placedAtLocal = placedAt!.toLocal();
        if (placedAtLocal.isBefore(now) && !OrderColorHelper.isSameDate(now, placedAtLocal)) {
          final formattedTime = DateFormat('hh:mm a').format(placedAtLocal);
          final formattedDate = DateFormat('dd MMM').format(placedAtLocal);
          return '$formattedDate, $formattedTime';
        }
      }
      return 'Take Now';
    }

    if (collectTimeVal == 'SCHEDULED' && scheduledTime != null) {
      final scheduledTimeLocal = scheduledTime!.toLocal();
      final formattedTime = DateFormat('hh:mm a').format(scheduledTimeLocal);
      final formattedDate = DateFormat('dd MMM').format(scheduledTimeLocal);

      if (scheduledTimeLocal.isBefore(now)) {
        return '$formattedDate, $formattedTime';
      }

      if (OrderColorHelper.isSameDate(now, scheduledTimeLocal)) {
        return 'Today, $formattedTime';
      }

      return '$formattedDate, $formattedTime';
    }

    return leftText;
  }

  Color _getBackgroundColor() {
    return OrderColorHelper.getOrderBackgroundColor(
      collectTime: collectTime,
      scheduledTime: scheduledTime,
      placedAt: placedAt,
      defaultColor: backgroundColor,
      sectionColor: sectionColor ?? order?.sectionColor,
      primarySectionColor: primarySectionColor ?? order?.primarySectionColor,
      order: order,
    );
  }

  String _getVehicleIconPath() {
    switch (vehicleType?.toUpperCase()) {
      case 'BICYCLE':
      case 'MOTORCYCLE':
        return IconPath.bike;
      case 'CAR':
        return IconPath.car;
      case 'VAN':
        return IconPath.van;
      case 'TRUCK':
        return IconPath.taxi;
      default:
        return iconPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 32;
    final handleSize = height - 12;
    final maxDragVal = (width / 2) - (handleSize / 2) - 8;
    final effectiveAcceptText = _getAcceptLabel();
    final effectiveBackgroundColor = _getBackgroundColor();
    final effectiveIconPath = _getVehicleIconPath();
    final effectiveTextColor = effectiveBackgroundColor.computeLuminance() < 0.45
        ? Colors.white
        : Colors.black;

    return GetBuilder<SwipeButtonController>(
      tag: uniqueTag,
      init: SwipeButtonController(),
      builder: (controller) {
        controller.maxDrag = maxDragVal;
        controller.minDrag = -maxDragVal;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 16,
                child: Obx(() => Opacity(
                      opacity: (1.0 - (controller.dragX.value / controller.maxDrag)).clamp(0.0, 1.0),
                      child: Text(
                        'Left To Decline',
                        style: getTextStyle(
                          color: effectiveTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )),
              ),
              Positioned(
                right: 16,
                child: Obx(() => Opacity(
                      opacity: (1.0 - ((-controller.dragX.value) / controller.maxDrag)).clamp(0.0, 1.0),
                      child: Text(
                        effectiveAcceptText,
                        style: getTextStyle(
                          color: effectiveTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )),
              ),
              Obx(() => Positioned(
                    left: (width / 2) - (handleSize / 2) + controller.dragX.value,
                    child: GestureDetector(
                      onPanStart: controller.onPanStart,
                      onPanUpdate: controller.onPanUpdate,
                      onPanEnd: (details) => controller.onPanEnd(details, onAccept, onDecline),
                      child: Container(
                        width: handleSize,
                        height: handleSize,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(effectiveIconPath, width: 24, height: 24),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
