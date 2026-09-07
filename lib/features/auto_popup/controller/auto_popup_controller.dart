import 'dart:async';

import 'package:ZipBee_Driver/core/services/socket_service.dart';
import 'package:ZipBee_Driver/features/auto_popup/model/auto_order_popup_model.dart';
import 'package:ZipBee_Driver/features/auto_popup/widgets/auto_order_popup_dialog.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:ZipBee_Driver/features/order_details/screen/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AutoPopupController extends GetxController {
  final Logger logger = Logger();

  SocketService? _socketService;
  Timer? _countdownTimer;
  bool _listenersAttached = false;
  bool _isPopupOpen = false;

  final currentPopup = Rxn<AutoOrderPopupModel>();
  final secondsLeft = 0.obs;
  final isWaitingForAcceptAck = false.obs;

  @override
  void onInit() {
    super.onInit();
    attachSocket(SocketService());
  }

  void attachSocket(SocketService socketService) {
    _socketService = socketService;
    if (_listenersAttached) {
      _removeListeners();
    }

    debugPrint('🔌 [AUTO POPUP] Attaching socket listeners for popup events');
    socketService.on('rider:order_popup', _handleOrderPopup);
    socketService.on('rider:order_accepted_confirmed', _handleAccepted);
    socketService.on('rider:popup_declined_ack', _handleDismissAck);
    socketService.on('rider:popup_expired', _handleDismissAck);
    socketService.on('rider:popup_error', _handlePopupError);
    socketService.on('rider:public_order_available', _handlePublicOrderAvailable);
    _listenersAttached = true;
  }

  void _handleOrderPopup(dynamic data) {
    debugPrint('🔔 [AUTO POPUP] rider:order_popup received: $data');
    final popup = AutoOrderPopupModel.fromSocket(data);
    if (popup.orderId == 0) {
      logger.w('Invalid rider:order_popup payload: $data');
      return;
    }

    _showPopup(popup);
  }

  void _showPopup(AutoOrderPopupModel popup) {
    if (_isPopupOpen) {
      _closeDialog();
    }

    currentPopup.value = popup;
    secondsLeft.value = popup.timeoutSeconds;
    isWaitingForAcceptAck.value = false;
    _isPopupOpen = true;
    _startCountdown();

    Get.dialog(
      const AutoOrderPopupDialog(),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }

  void acceptPopup() {
    final popup = currentPopup.value;
    if (popup == null || isWaitingForAcceptAck.value) return;

    isWaitingForAcceptAck.value = true;
    _stopCountdown();
    debugPrint('📤 [AUTO POPUP] Emitting rider:accept_popup for orderId: ${popup.orderId}');
    _socketService?.emit('rider:accept_popup', {'orderId': popup.orderId});
  }

  void declinePopup() {
    final popup = currentPopup.value;
    if (popup == null) return;

    debugPrint('📤 [AUTO POPUP] Emitting rider:decline_popup for orderId: ${popup.orderId}');
    _socketService?.emit('rider:decline_popup', {
      'orderId': popup.orderId,
      'reason': 'Declined by driver',
    });
    _dismissPopup();
  }

  void _timeoutPopup() {
    final popup = currentPopup.value;
    if (popup == null) return;

    debugPrint('📤 [AUTO POPUP] Emitting rider:popup_timeout_ack for orderId: ${popup.orderId}');
    _socketService?.emit('rider:popup_timeout_ack', {'orderId': popup.orderId});
    _dismissPopup();
  }

  void _handleAccepted(dynamic data) {
    debugPrint('✅ [AUTO POPUP] rider:order_accepted_confirmed received: $data');
    _stopCountdown();
    isWaitingForAcceptAck.value = false;
    final orderArg = _orderArgument(data) ?? _orderArgument(currentPopup.value);
    final String message = data is Map && data['message'] != null
        ? data['message'].toString()
        : '✅ Order locked! Navigate to pickup.';

    _closeDialog();
    EasyLoading.showSuccess(message);

    Get.dialog(
      _resultDialog(
        icon: Icons.check_circle,
        iconColor: Colors.green,
        title: 'You got the Order!',
        buttonText: 'Done',
        onPressed: () {
          Get.back();
          Get.to(() => OrderDetailsScreen(), arguments: orderArg);
        },
      ),
      barrierDismissible: false,
    );
  }

  void _handleDismissAck(dynamic data) {
    debugPrint('ℹ️ [AUTO POPUP] Dismiss ack/expired received: $data');
    _dismissPopup();
  }

  void _handlePopupError(dynamic data) {
    debugPrint('❌ [AUTO POPUP] rider:popup_error received: $data');
    _dismissPopup();
    final message = data is Map && data['message'] != null
        ? data['message'].toString()
        : 'Popup already expired or assigned to another driver';
    EasyLoading.showError(message);
  }

  void _handlePublicOrderAvailable(dynamic data) {
    debugPrint('📢 [AUTO POPUP] rider:public_order_available received: $data');
  }

  Object? _orderArgument(dynamic data) {
    if (data is AutoOrderPopupModel) {
      if (data.rawOrder != null) {
        try {
          return OrderModel.fromJson(data.rawOrder!);
        } catch (_) {
          return data.orderId;
        }
      }
      return data.orderId;
    }

    final map = data is Map<String, dynamic>
        ? data
        : data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};
    final order = map['order'];
    if (order is Map) {
      try {
        return OrderModel.fromJson(Map<String, dynamic>.from(order));
      } catch (_) {
        return map['orderId'] ?? map['order_id'] ?? currentPopup.value?.orderId;
      }
    }
    return map['orderId'] ?? map['order_id'] ?? currentPopup.value?.orderId;
  }

  Widget _resultDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 55, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCountdown() {
    _stopCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        _stopCountdown();
        _timeoutPopup();
        return;
      }
      secondsLeft.value--;
    });
  }

  void _dismissPopup() {
    _stopCountdown();
    isWaitingForAcceptAck.value = false;
    currentPopup.value = null;
    _closeDialog();
  }

  void _closeDialog() {
    if (_isPopupOpen && Get.isDialogOpen == true) {
      Get.back();
    }
    _isPopupOpen = false;
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _removeListeners() {
    _socketService?.off('rider:order_popup');
    _socketService?.off('rider:order_accepted_confirmed');
    _socketService?.off('rider:popup_declined_ack');
    _socketService?.off('rider:popup_expired');
    _socketService?.off('rider:popup_error');
    _socketService?.off('rider:public_order_available');
    _listenersAttached = false;
  }

  @override
  void onClose() {
    _stopCountdown();
    _removeListeners();
    super.onClose();
  }
}
