import 'package:ZipBee_Driver/core/utils/constants/stripe_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class TopUpStripeHandler {
  static bool _initialized = false;

  /// Initialize Stripe with proper error handling
  static Future<bool> initializeStripe() async {
    try {
      if (_initialized) {
        debugPrint('✅ Stripe already initialized');
        return true;
      }

      // Validate keys
      if (!StripeKeys.isConfigured()) {
        debugPrint('❌ Stripe keys not properly configured');
        EasyLoading.showError('Payment configuration error');
        return false;
      }

      debugPrint('🔄 Initializing Stripe with public key...');
      Stripe.publishableKey = StripeKeys.stripePublicKey;

      _initialized = true;
      debugPrint('✅ Stripe initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Stripe Init Error: $e');
      EasyLoading.showError('Failed to initialize payment');
      return false;
    }
  }

  /// Present Stripe payment sheet with proper handling
  static Future<bool> presentPaymentSheet({
    required String clientSecret,
    required double amount,
  }) async {
    try {
      debugPrint('[STRIPE] presentPaymentSheet start: amount=\$${amount.toStringAsFixed(2)}, clientSecret=$clientSecret');
      // Validate inputs
      if (clientSecret.isEmpty) {
        debugPrint('❌ [STRIPE] Invalid client secret (empty)');
        EasyLoading.showError('Payment configuration error');
        return false;
      }

      if (amount <= 0) {
        debugPrint('❌ [STRIPE] Invalid amount: $amount');
        EasyLoading.showError('Invalid amount');
        return false;
      }

      debugPrint('🔄 [STRIPE] Initializing payment sheet with amount: \$${amount.toStringAsFixed(2)}');
      EasyLoading.show(status: 'Opening payment sheet...');

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ZipBee Driver',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.amber),
            shapes: PaymentSheetShape(borderRadius: 12),
          ),
        ),
      );

      debugPrint('✅ [STRIPE] Payment sheet initialized successfully');
      EasyLoading.dismiss();

      // Present the payment sheet
      debugPrint('🔄 [STRIPE] Awaiting Stripe.instance.presentPaymentSheet()...');
      await Stripe.instance.presentPaymentSheet();

      debugPrint('✅ [STRIPE] presentPaymentSheet completed normally without exception for amount: \$${amount.toStringAsFixed(2)}');
      EasyLoading.showSuccess('Payment Successful!');
      return true;
    } on StripeException catch (e) {
      EasyLoading.dismiss();
      debugPrint('⚠️ [STRIPE] presentPaymentSheet caught StripeException: ${e.error.localizedMessage}');
      debugPrint('[STRIPE] Stripe error code: ${e.error.code}, message: ${e.error.message}');
      
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('ℹ️ [STRIPE] Payment cancelled by user');
        EasyLoading.showInfo('Payment cancelled');
      } else {
        EasyLoading.showError('Payment failed: ${e.error.localizedMessage}');
      }
      return false;
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('❌ [STRIPE] presentPaymentSheet caught unexpected error: $e');
      EasyLoading.showError('Something went wrong');
      return false;
    }
  }

  /// Reset initialization state (useful for testing)
  static void reset() {
    _initialized = false;
    debugPrint('ℹ️ Stripe handler reset');
  }
}