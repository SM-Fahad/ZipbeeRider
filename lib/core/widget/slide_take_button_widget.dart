import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/common/style/global_text_style.dart';

class SlideToTakeButtonWidget extends StatelessWidget {
  final dynamic ctrl;
  final double width;
  final Color firstColor;
  final Color secondColor;
  final String? collectTime;
  final DateTime? scheduledTime;
  final DateTime? placedAt;
  final String? sectionColor;
  final String? primarySectionColor;
  final OrderModel? order;

  const SlideToTakeButtonWidget({
    super.key,
    required this.ctrl,
    required this.width,
    required this.firstColor,
    required this.secondColor,
    this.collectTime,
    this.scheduledTime,
    this.placedAt,
    this.sectionColor,
    this.primarySectionColor,
    this.order,
  });

  String _getAcceptLabel() {
    final normalizedCollectTime = collectTime?.toUpperCase();
    final now = DateTime.now();

    if (normalizedCollectTime == 'ASAP') {
      if (placedAt != null) {
        final placedAtLocal = placedAt!.toLocal();
        if (placedAtLocal.isBefore(now) && !OrderColorHelper.isSameDate(now, placedAtLocal)) {
          final formattedTime = DateFormat('hh:mm a').format(placedAtLocal);
          final formattedDate = DateFormat('dd MMM').format(placedAtLocal);
          return '$formattedDate, $formattedTime';
        }
      }
      return 'Now';
    }

    if (normalizedCollectTime == 'SCHEDULED' && scheduledTime != null) {
      final localScheduledTime = scheduledTime!.toLocal();
      final formattedTime = DateFormat('hh:mm a').format(localScheduledTime);
      final formattedDate = DateFormat('dd MMM').format(localScheduledTime);

      if (localScheduledTime.isBefore(now)) {
        return '$formattedDate, $formattedTime';
      }

      if (OrderColorHelper.isSameDate(now, localScheduledTime)) {
        return 'Today, $formattedTime';
      }

      return '$formattedDate, $formattedTime';
    }

    return 'Accept';
  }

  Color _getBackgroundColor(double progress) {
    final baseColor = OrderColorHelper.getOrderBackgroundColor(
      collectTime: collectTime,
      scheduledTime: scheduledTime,
      placedAt: placedAt,
      defaultColor: firstColor,
      sectionColor: sectionColor ?? order?.sectionColor,
      primarySectionColor: primarySectionColor ?? order?.primarySectionColor,
      order: order,
    );

    final endColor = collectTime?.toUpperCase() == 'ASAP'
        ? AppColors.seconderyButtonColor
        : secondColor;

    return Color.lerp(baseColor, endColor, progress) ?? baseColor;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    final double bgHeight = w * 0.16;
    final double buttonHeight = w * 0.11;
    final double buttonWidth = w * 0.14;
    final double leftGap = w * 0.03;
    final double fontSize = w * 0.031;
    final double maxDrag = width - buttonWidth - leftGap;

    return Obx(() {
      double progress = (ctrl.dragX.value / maxDrag).clamp(0.0, 1.0);
      final effectiveAcceptText = _getAcceptLabel();
      final effectiveBackgroundColor = _getBackgroundColor(progress);

      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: bgHeight,
            width: width,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 1 - progress,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          // effectiveAcceptText,
                          "SLIDE TO TAKE",
                          style: getTextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          // "SLIDE TO TAKE",
                          effectiveAcceptText,
                          style: getTextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: ctrl.dragX.value + leftGap,
            top: (bgHeight - buttonHeight) / 2,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                ctrl.dragX.value += details.delta.dx;

                if (ctrl.dragX.value < 0) ctrl.dragX.value = 0;
                if (ctrl.dragX.value > maxDrag) ctrl.dragX.value = maxDrag;
              },
              onHorizontalDragEnd: (_) {
                if (ctrl.dragX.value >= maxDrag * 0.88) {
                  ctrl.onSlideComplete();
                } else {
                  animateBack(ctrl, maxDrag);
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                height: buttonHeight,
                width: buttonWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    IconPath.playicon,
                    height: buttonHeight * 0.45,
                    width: buttonWidth * 0.45,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void animateBack(dynamic ctrl, double maxDrag) {
    double current = ctrl.dragX.value;
    int duration = 240;
    const int frameRate = 16;
    double step = current / (duration / frameRate);

    Future.doWhile(() async {
      if (ctrl.dragX.value <= 0) return false;

      ctrl.dragX.value = (ctrl.dragX.value - step).clamp(0, maxDrag);
      await Future.delayed(const Duration(milliseconds: frameRate));

      return ctrl.dragX.value > 0;
    });
  }
}
