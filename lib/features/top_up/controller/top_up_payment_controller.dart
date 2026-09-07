import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../service/top_up_payment_service.dart';
import '../service/top_up_stripe_handler.dart';

class TopUpPaymentController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<bool> processTopUp({
    required double amount,
  }) async {
    if (amount <= 0) {
      EasyLoading.showError('Please enter a valid amount');
      return false;
    }

    isLoading.value = true;
    bool isLoaderShowing = false;
    try {
      EasyLoading.show(status: 'Processing payment request...');
      isLoaderShowing = true;
      debugPrint('💰 Starting TopUp process for amount: \$${amount.toStringAsFixed(2)}');

      // Step 1: Get clientSecret from backend
      debugPrint('📤 Sending payment request to backend...');
      final response = await TopUpPaymentService.addMoney(
        amount: amount,
        currency: 'sgd',
      );

      if (!response['success']) {
        if (isLoaderShowing) {
          EasyLoading.dismiss();
          isLoaderShowing = false;
        }
        final errorMsg = response['body']?['message'] ?? 'Failed to initiate payment';
        debugPrint('❌ Backend error: $errorMsg');
        EasyLoading.showError(errorMsg);
        return false;
      }

      final clientSecret = response['body']['data']?['clientSecret'];
      if (clientSecret == null || clientSecret.isEmpty) {
        if (isLoaderShowing) {
          EasyLoading.dismiss();
          isLoaderShowing = false;
        }
        debugPrint('❌ No clientSecret received from backend');
        EasyLoading.showError('Payment configuration error');
        return false;
      }

      debugPrint('✅ Received clientSecret from backend');

      // Step 2: Initialize Stripe
      debugPrint('🔄 Initializing Stripe...');
      final initialized = await TopUpStripeHandler.initializeStripe();
      if (!initialized) {
        if (isLoaderShowing) {
          EasyLoading.dismiss();
          isLoaderShowing = false;
        }
        debugPrint('❌ Failed to initialize Stripe');
        return false;
      }

      // Step 3: Present payment sheet
      debugPrint('📱 Presenting Stripe payment sheet...');
      if (isLoaderShowing) {
        EasyLoading.dismiss();
        isLoaderShowing = false;
      }
      final success = await TopUpStripeHandler.presentPaymentSheet(
        clientSecret: clientSecret,
        amount: amount,
      );

      if (success) {
        debugPrint('✅ Payment successful!');
        return true;
      } else {
        debugPrint('⚠️ Payment failed or cancelled');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error in processTopUp: $e');
      if (isLoaderShowing) {
        EasyLoading.dismiss();
        isLoaderShowing = false;
      }
      EasyLoading.showError('Something went wrong: $e');
      return false;
    } finally {
      isLoading.value = false;
      if (isLoaderShowing) {
        EasyLoading.dismiss();
      }
    }
  }
}