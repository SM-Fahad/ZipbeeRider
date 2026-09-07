import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/account/controller/account_controller.dart';
import 'package:ZipBee_Driver/features/payment_method/service/payment_method_service.dart';
import 'package:ZipBee_Driver/features/payment_method/widgets/withdraw_dialog.dart';
import 'package:ZipBee_Driver/features/statistics/screen/statistics_screen.dart';
import 'package:ZipBee_Driver/features/top_up/screen/top_up_screen.dart';
import 'package:ZipBee_Driver/features/wallet_history/screen/wallet_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class PaymentMethodController extends GetxController {
  // ================== OBSERVABLES ==================
  RxDouble currentWalletBalance = 0.0.obs;
  RxBool isLoading = false.obs;

  // ================== LIFECYCLE ==================
  @override
  void onInit() {
    super.onInit();
    getWalletBalance();
  }

  // ================== API CALL ==================
  Future<void> getWalletBalance() async {
    try {
      isLoading.value = true;

      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        EasyLoading.showError('User not logged in');
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final data = decoded['data'];

        currentWalletBalance.value = (data['currentWalletBalance'] ?? 0)
            .toDouble();
      } else {
        EasyLoading.showError('Failed to load wallet (${response.statusCode})');
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================== ACTIONS ==================
  void topUp() {
    Get.to(() => TopUpScreen())?.then((_) {
      getWalletBalance();
      if (Get.isRegistered<AccountController>()) {
        Get.find<AccountController>().fetchProfile();
      }
    });
  }

  void withdraw() {
    Get.dialog(
      WithdrawDialog(
        onApply: _performWithdraw,
      ),
    );
  }

  Future<void> _performWithdraw(double amount) async {
    try {
      EasyLoading.show(status: 'Processing withdrawal...');

      final response = await PaymentMethodService.withdrawMoney(amount);

      if (response != null && response.success == true) {
        EasyLoading.showSuccess('Withdrawal successful!');
        getWalletBalance();
        if (Get.isRegistered<AccountController>()) {
          Get.find<AccountController>().fetchProfile();
        }
      } else {
        final errorMsg = response?.message ?? 'Failed to process withdrawal';
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }

  void received() {
    debugPrint('📲 PaymentMethodController: Navigating to Wallet History');
    Get.to(() => WalletHistoryScreen())?.then((_) {
      debugPrint('📲 PaymentMethodController: Returned from Wallet History');
      getWalletBalance();
      if (Get.isRegistered<AccountController>()) {
        Get.find<AccountController>().fetchProfile();
      }
    });
  }

  void Statistics() {
    Get.to(() => StatisticsScreen());
  }

  // ================== BANK DETAILS ==================
  Future<void> connectBankDetails() async {
    try {
      EasyLoading.show(status: 'Connecting to Stripe...');

      final response = await PaymentMethodService.createExpressAccount();

      if (response != null && response.success && response.data.url.isNotEmpty) {
        EasyLoading.dismiss();

        // Launch the Stripe account link URL in browser
        final url = response.data.url;
        if (await canLaunch(url)) {
          await launch(url, forceSafariVC: false, forceWebView: false);
        } else {
          EasyLoading.showError('Could not open Stripe connection');
        }
      } else {
        final errorMsg = (response != null && response.message.isNotEmpty)
            ? response.message
            : 'Failed to connect bank details';
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }

  Future<void> resetStripe() async {
    try {
      EasyLoading.show(status: 'Resetting Stripe...');

      final response = await PaymentMethodService.resetExpressAccount();

      if (response != null && response.success && response.data.url.isNotEmpty) {
        EasyLoading.dismiss();

        // Launch the Stripe account link URL in browser
        final url = response.data.url;
        if (await canLaunch(url)) {
          await launch(url, forceSafariVC: false, forceWebView: false);
        } else {
          EasyLoading.showError('Could not open Stripe reset connection');
        }
      } else {
        final errorMsg = (response != null && response.message.isNotEmpty)
            ? response.message
            : 'Failed to reset express account';
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }
}
