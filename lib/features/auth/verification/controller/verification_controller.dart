import 'dart:async';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/core/services/firebase/firebase_notification_permission.dart';
import 'package:ZipBee_Driver/features/auth/login/auth%20service/auth_service.dart';
import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:ZipBee_Driver/features/auth/rider_details/screen/rider_details_screen.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class VerificationController extends GetxController {
  // ================= OTP INPUT =================
  final List<TextEditingController> pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  RxString otp = ''.obs;

  // ================= TIMER =================
  final RxInt secondsLeft = 50.obs;
  Timer? timer;

  // ================= STATE =================
  final RxBool isVerifying = false.obs;

  // ================= DATA =================
  RxString email = ''.obs;
  late String from; // signup | login | forget

  bool get canResend => secondsLeft.value == 0;
  bool get canVerify => otp.value.length == 4 && !isVerifying.value;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};
    email.value = args['email'] ?? '';
    from = args['from'] ?? 'signup';

    for (var c in pinControllers) {
      c.addListener(_onPinsChanged);
    }

    sendOtp();
    _startTimer();
  }

  // ================= OTP =================
  void _onPinsChanged() {
    otp.value = pinControllers.map((c) => c.text).join();
  }

  void onPinChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  // ================= TIMER =================
  void _startTimer({int from = 50}) {
    timer?.cancel();
    secondsLeft.value = from;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value == 0) {
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  // ================= SEND OTP =================
  Future<void> sendOtp() async {
    try {
      await AuthService.sendOtp(email: email.value);
      EasyLoading.showSuccess("OTP has been sent to your email");
    } catch (_) {
      EasyLoading.showError("Failed to send OTP");
    }
  }

  void resendCode() {
    if (!canResend) return;
    sendOtp();
    _startTimer(from: 50);
  }

  // ================= VERIFY =================
  Future<void> verifyCode() async {
    if (!canVerify) return;

    isVerifying.value = true;

    try {
      String endpoint;

      if (from == 'login') {
        endpoint = ApiEndPoint.loginVerify;
      } else if (from == 'forget') {
        endpoint = ApiEndPoint.forgetVerify;
      } else {
        endpoint = ApiEndPoint.verify; // signup
      }

      final res = await AuthService.verifyOtp(
        email: email.value,
        otp: otp.value,
        endpoint: endpoint,
      );

      if (res['success'] != true || res['access_token'] == null) {
        throw Exception("OTP Invalid");
      }

      await SharedPreferencesHelper.saveToken(res['access_token']);
      await sendCurrentFcmTokenToBackend();

      EasyLoading.showSuccess("Email verified successfully");

      if (from == 'login') {
        final profileCheckController =
            Get.isRegistered<ProfileCheckController>()
                ? Get.find<ProfileCheckController>()
                : Get.put(ProfileCheckController(autoCheckOnInit: false));
        await profileCheckController.checkProfile();
      } else {
        Get.offAll(() => RiderDetailsScreen());
      }
    } catch (_) {
      EasyLoading.showError("Invalid OTP");
    } finally {
      isVerifying.value = false;
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    for (var c in pinControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
