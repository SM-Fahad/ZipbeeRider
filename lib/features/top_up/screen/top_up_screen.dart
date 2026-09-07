// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/payment_method/controller/payment_method_controller.dart';
import 'package:ZipBee_Driver/features/top_up/controller/top_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpScreen extends StatelessWidget {
  final TopUpController controller = Get.put(TopUpController());
  final PaymentMethodController paymentMethodController = Get.put(PaymentMethodController());

  TopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: Get.back,
            ),
            title: Text(
              "Top up",
              style: getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --------- Balance Box ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: AppColors.onboardingIndicatorActive,
              child: Column(
                children: [
                  Text(
                    "Total Balance",
                    style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        "\$${paymentMethodController.currentWalletBalance.value.toStringAsFixed(2)}",
                        style: getTextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // --------- Amount Box ----------
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                margin: const EdgeInsets.symmetric(horizontal: 120),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    "\$${controller.selectedAmount.value}",
                    style: getTextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --------- Preset Buttons ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                presetButton("\$10", 10),
                presetButton("\$20", 20),
                presetButton("\$40", 40),
                presetButton("\$1000", 1000),
              ],
            ),

            const SizedBox(height: 20),

            // --------- Top Up Button (Stripe Trigger) ----------
            Obx(
              () {
                bool isProcessing = controller.paymentController.isLoading.value;
                bool hasAmount = controller.selectedAmount.value > 0;

                return GestureDetector(
                  onTap: (hasAmount && !isProcessing)
                      ? () => controller.startPayment(context)
                      : null,
                  child: Container(
                    height: 50,
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      color: (hasAmount && !isProcessing)
                          ? AppColors.primaryButtonColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isProcessing
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Top Up",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            

            // --------- Keypad ----------
            Container(
              color: Colors.blueGrey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                children: [
                  keypadRow(["1", "2", "3"]),
                  keypadRow(["4", "5", "6"]),
                  keypadRow(["7", "8", "9"]),
                  keypadRow(["clear", "0", "back"]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget presetButton(String label, int amount) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.setAmount(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: controller.selectedAmount.value == amount
                ? AppColors.primaryButtonColor
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.4)),
          ),
          child: Text(
            label,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget keypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => keypadButton(key)).toList(),
    );
  }

  Widget keypadButton(String key) {
    return GestureDetector(
      onTap: () {
        if (key == "clear")
          controller.clearAmount();
        else if (key == "back")
          controller.addDigit("back");
        else
          controller.addDigit(key);
      },
      child: Container(
        height: 55,
        width: 90,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.4)),
        ),
        child: Center(
          child: key == "back"
              ? const Icon(Icons.backspace_outlined, size: 26)
              : key == "clear"
                  ? const Icon(Icons.close, size: 28)
                  : Text(
                      key,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
        ),
      ),
    );
  }
}