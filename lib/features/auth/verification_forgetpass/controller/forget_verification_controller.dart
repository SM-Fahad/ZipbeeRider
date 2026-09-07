import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../core/api_end_point/api_end_point.dart';
import '../../reset_password/screen/reset_password_screen.dart';

class ForgetVerificationController extends GetxController {
  final List<TextEditingController> pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  RxString otp = ''.obs;
  RxInt secondsLeft = 50.obs;
  Timer? timer;
  RxBool isVerifying = false.obs;

  RxString email = ''.obs;
  RxString phone = ''.obs;

  bool get canResend => secondsLeft.value == 0;
  bool get canVerify => otp.value.length == 4 && !isVerifying.value;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};
    email.value = args['email'] ?? '';
    phone.value = args['phone'] ?? '';

    for (var c in pinControllers) {
      c.addListener(_onPinsChanged);
    }

    _startTimer();
  }

  void _onPinsChanged() {
    otp.value = pinControllers.map((c) => c.text).join();
  }

  void onPinChanged(String value, int index) {
    if (value.length > 1) {
      final last = value.substring(value.length - 1);
      pinControllers[index].text = last;
      pinControllers[index].selection = const TextSelection.collapsed(
        offset: 1,
      );
    }

    if (value.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

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

  void resendCode() {
    if (!canResend) return;
    _startTimer(from: 50);
    // call resend OTP API if backend supports
  }

  Future<void> verifyCode() async {
    if (!canVerify) return;

    isVerifying.value = true;

    try {
      final body = {
        if (email.value.isNotEmpty) "email": email.value,
        if (phone.value.isNotEmpty) "phone": phone.value,
        "otp": otp.value,
      };

      debugPrint("VERIFY BODY => $body");

      final response = await http.post(
        Uri.parse(ApiEndPoint.forgetVerify),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);
      debugPrint("VERIFY RESPONSE => $responseBody");

      if (responseBody['success'] == true) {
        EasyLoading.showSuccess(responseBody['message'] ?? "OTP verified successfully");

        /// ✅ Navigate WITHOUT token
        Get.offAll(
          () => ResetPasswordScreen(),
          arguments: {
            if (email.value.isNotEmpty) "email": email.value,
            if (phone.value.isNotEmpty) "phone": phone.value,
          },
        );
      } else {
        EasyLoading.showError(responseBody['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      debugPrint("VERIFY ERROR => $e");
      EasyLoading.showError("OTP verification failed");
    } finally {
      isVerifying.value = false;
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    for (var c in pinControllers) {
      c.removeListener(_onPinsChanged);
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
