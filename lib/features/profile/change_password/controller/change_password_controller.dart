import 'dart:convert';

import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../core/api_end_point/api_end_point.dart';

class ChangePasswordController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var hideCurrent = true.obs;
  var hideNew = true.obs;
  var hideConfirm = true.obs;

  var isLoading = false.obs;

  void toggleCurrent() => hideCurrent.value = !hideCurrent.value;
  void toggleNew() => hideNew.value = !hideNew.value;
  void toggleConfirm() => hideConfirm.value = !hideConfirm.value;

  Future<void> changePassword() async {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    // --- Validation ---
    if (current.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      EasyLoading.showError("Please fill all fields");
      return;
    }

    if (current.length < 5 || newPass.length < 5) {
      EasyLoading.showError("Passwords must be at least 5 characters");
      return;
    }

    if (newPass != confirmPass) {
      EasyLoading.showError("New password and confirm password do not match");
      return;
    }

    try {
      isLoading.value = true;

      // Retrieve token and email from SharedPreferences
      final token = await SharedPreferencesHelper.getAccessToken();
      final email = await SharedPreferencesHelper.getEmail();

      final response = await http.post(
        Uri.parse(ApiEndPoint.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "email": email,
          "oldPassword": current,
          "newPassword": newPass,
        }),
      );

      isLoading.value = false;

      final body = jsonDecode(response.body);
      debugPrint(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        EasyLoading.showSuccess(
          body['message'] ?? "Password changed successfully",
        );

        // Clear input fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        EasyLoading.showError(body['message'] ?? "Failed to change password");
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.showError("Something went wrong: $e");
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
