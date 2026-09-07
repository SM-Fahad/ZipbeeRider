import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ZipBee_Driver/features/top_up/controller/top_up_payment_controller.dart';

class WalletController extends GetxController {
  final cardHolderNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();

  final TopUpPaymentController paymentController = Get.put(
    TopUpPaymentController(),
  );

  var isButtonEnabled = false.obs;
  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    cardHolderNameController.addListener(_validateForm);
    cardNumberController.addListener(_validateForm);
    expiryDateController.addListener(_validateForm);
    cvvController.addListener(_validateForm);
  }

  void _validateForm() {
    if (cardHolderNameController.text.isNotEmpty &&
        cardNumberController.text.isNotEmpty &&
        expiryDateController.text.isNotEmpty &&
        cvvController.text.isNotEmpty) {
      isButtonEnabled.value = true;
    } else {
      isButtonEnabled.value = false;
    }
  }

  void onPayContinue() {}

  /// Process Background Check Payment ($50 fixed)
  Future<void> processBackgroundCheckPayment(Function onPaymentSuccess) async {
    isProcessing.value = true;
    try {
      final success = await paymentController.processTopUp(
        amount: 50.0,
      );
      if (success) {
        onPaymentSuccess();
      }
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    cardHolderNameController.dispose();
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.onClose();
  }

  // void continueAction() {
  //   if (isButtonEnabled.value) {
  //     Get.dialog(
  //       Dialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Stack(
  //           children: [
  //             // Main dialog content
  //             SizedBox(
  //               width: 307,
  //               child: Padding(
  //                 padding: EdgeInsets.all(20.0),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Container(
  //                       height: 90,
  //                       width: 90,
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         shape: BoxShape.circle,
  //                         border: Border.all(
  //                           color: Colors.greenAccent,
  //                           width: 30,
  //                         ),
  //                       ),
  //                       child: Center(
  //                         child: Image.asset(
  //                           IconPath.right,
  //                           height: 13,
  //                           width: 14,
  //                           color: AppColors.onboardingIndicatorActive,
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),
  //                     Text(
  //                       "Congratulations!",
  //                       style: getTextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                     SizedBox(height: 10),
  //                     Text(
  //                       "Payment successful. Your account has been verified and activated for job access.",
  //                       style: getTextStyle(
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w400,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                     SizedBox(height: 30),
  //                     SizedBox(
  //                       width: 188,
  //                       height: 48,
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           // Get.toNamed(AppRoutes.getDistanceRadiusScreen());
  //                           Get.back();
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor:
  //                               AppColors.onboardingIndicatorActive,
  //                         ),
  //                         child: Text(
  //                           'Go to Home',
  //                           style: getTextStyle(
  //                             color: Colors.white,
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       barrierDismissible: false,
  //     );
  //   }
  // }
}
