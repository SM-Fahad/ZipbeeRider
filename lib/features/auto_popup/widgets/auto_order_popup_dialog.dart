import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/auto_popup/controller/auto_popup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoOrderPopupDialog extends GetView<AutoPopupController> {
  const AutoOrderPopupDialog({super.key});

  String _formatRaiderToPickupKm(double? value) {
    if (value == null) return '';
    final distStr = value == value.toInt() ? value.toInt().toString() : value.toStringAsFixed(2);
    return '~$distStr Km';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final popup = controller.currentPopup.value;
      if (popup == null) return const SizedBox.shrink();

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 350,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryButtonColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(onClose: controller.declinePopup),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                popup.routeType == 'ROUND'
                                    ? IconPath.roundtrip
                                    : popup.routeType == 'ONE_WAY'
                                        ? IconPath.oneway
                                        : IconPath.exparess,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.local_shipping_outlined,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (popup.raiderToPickupKm != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3CD),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _formatRaiderToPickupKm(popup.raiderToPickupKm),
                                      style: getTextStyle(
                                        color: const Color(0xFF856404),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        popup.deliveryType.toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: getTextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    if (popup.deliveryTypeIconPath != null) ...[
                                      const SizedBox(width: 4),
                                      Image.asset(
                                        popup.deliveryTypeIconPath!,
                                        width: 16,
                                        height: 16,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Text(
                              //   'Order #${popup.orderId}',
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
                                    popup.displayExtraFee > 0
                                        ? '\$${popup.displayExtraFee.toStringAsFixed(2)} + \$${popup.displayBasePay.toStringAsFixed(2)}'
                                        : '\$${popup.displayBasePay.toStringAsFixed(2)}',
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${popup.distanceText}  |  ${popup.estimatedTimeText}',
                                style: getTextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
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
                              popup.pickupAddress,
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
                          if (popup.displayStopsCount >= 1)
                            Text(
                              popup.displayStopsCount == 1
                                  ? '1 Stop'
                                  : '${popup.displayStopsCount} Stops',
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
                            popup.isRoundTrip
                                ? IconPath.location_blue
                                : IconPath.location_red,
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              popup.finalDropAddress,
                              style: getTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        popup.comment,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 41,
                        child: ElevatedButton(
                          onPressed: controller.isWaitingForAcceptAck.value
                              ? null
                              : controller.acceptPopup,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primaryButtonColor,
                            disabledBackgroundColor: AppColors.greyButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            controller.isWaitingForAcceptAck.value
                                ? 'Accepting Order...'
                                : 'Accept & Take Now',
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _Header extends GetView<AutoPopupController> {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.only(left: 12, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: const BoxDecoration(
              color: AppColors.primaryButtonColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Incoming order',
              style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          Obx(
            () => Text(
              '${controller.secondsLeft.value}s',
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.red, size: 28),
            tooltip: 'Decline',
          ),
        ],
      ),
    );
  }
}
