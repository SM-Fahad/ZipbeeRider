import 'package:ZipBee_Driver/features/top_up/controller/top_up_payment_controller.dart';
import 'package:ZipBee_Driver/features/top_up/widget/top_up_success_dailog_widget.dart';
import 'package:ZipBee_Driver/features/account/controller/account_controller.dart';
import 'package:ZipBee_Driver/features/payment_method/controller/payment_method_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpController extends GetxController {
  var selectedAmount = 0.obs;

  final TopUpPaymentController paymentController = Get.put(
    TopUpPaymentController(),
  );

  void setAmount(int value) {
    selectedAmount.value = value;
  }

  void addDigit(String digit) {
    String current = selectedAmount.value.toString();
    if (digit == "back") {
      if (current.length > 1) {
        selectedAmount.value = int.parse(
          current.substring(0, current.length - 1),
        );
      } else {
        selectedAmount.value = 0;
      }
    } else {
      String newValue = (current == "0") ? digit : current + digit;
      if (newValue.length < 10) {
        selectedAmount.value = int.parse(newValue);
      }
    }
  }

  void clearAmount() {
    selectedAmount.value = 0;
  }

  /// Stripe payment starting function
  Future<void> startPayment(BuildContext context) async {
    if (selectedAmount.value <= 0) return;

    final success = await paymentController.processTopUp(
      amount: selectedAmount.value.toDouble(),
    );

    if (success) {
      if (Get.isRegistered<PaymentMethodController>()) {
        Get.find<PaymentMethodController>().getWalletBalance();
      }
      if (Get.isRegistered<AccountController>()) {
        Get.find<AccountController>().fetchProfile();
      }

      // Show success dialog using Get.bottomSheet
      Get.bottomSheet(
        const TopUpSuccessBottomSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      clearAmount();
    }
  }
}
