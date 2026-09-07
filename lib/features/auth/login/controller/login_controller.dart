import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/core/services/firebase/firebase_notification_permission.dart';
import 'package:ZipBee_Driver/features/auth/login/auth%20service/auth_service.dart';
import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:ZipBee_Driver/features/auth/verification/screen/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginSignupController extends GetxController {
  /// UI state
  var isLoginSelected = true.obs;
  var rank = "".obs;

  /// Controllers
  late TextEditingController phoneController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController referralCodeController;

  /// Reactive phone helpers
  RxString selectedCountryCode = '+1'.obs;
  RxString phoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();

    phoneController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    referralCodeController = TextEditingController();
    selectedCountryCode.value = '+65';

    phoneController.addListener(() {
      phoneNumber.value = phoneController.text;
    });
  }

  void toggleSelection(bool isLogin) {
    isLoginSelected.value = isLogin;
  }

  void clearPhone() {
    phoneController.clear();
    phoneNumber.value = '';
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }

  // ===================== LOGIN =====================
  Future<void> onLoginPressed() async {
    final identifier = emailController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty) {
      return showError("Please enter Email, Phone or Username");
    }
    if (password.isEmpty) return showError("Please enter your password");

    // Determine if identifier is email, phone, or username
    Map<String, dynamic> loginData = {"password": password};

    if (GetUtils.isEmail(identifier)) {
      loginData["email"] = identifier;
    } else if (RegExp(r'^[0-9+]+$').hasMatch(identifier)) {
      loginData["phone"] = identifier;
    } else {
      loginData["username"] = identifier;
    }

    try {
      EasyLoading.show(status: "Logging in...");
      // AuthService.login expects a Map<String, dynamic> with keys like "email", "phone", or "username" along with "password"
      final res = await AuthService.login(loginData);

      if (res["success"] == true && res["access_token"] != null) {
        await SharedPreferencesHelper.saveToken(res["access_token"]);
        if (res["refresh_token"] != null && res["refresh_token"].toString().isNotEmpty) {
          await SharedPreferencesHelper.saveRefreshToken(res["refresh_token"]);
        }

        try {
          await sendCurrentFcmTokenToBackend();
        } catch (e) {
          debugPrint("FCM token update error during login: $e");
        }

        final profileData = await fetchProfile();
        EasyLoading.dismiss();

        final profileCheckController =
            Get.isRegistered<ProfileCheckController>()
            ? Get.find<ProfileCheckController>()
            : Get.put(ProfileCheckController(autoCheckOnInit: false));

        await profileCheckController.processProfileData(profileData);
      } else {
        EasyLoading.dismiss();
        showError(res["message"]?.toString() ?? "Login failed");
      }
    } catch (e, stack) {
      debugPrint("LOGIN FLOW ERROR: $e\n$stack");
      EasyLoading.dismiss();
      showError("Login failed: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("FETCH PROFILE RESPONSE: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        Map<String, dynamic> data;
        if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is Map<String, dynamic>) {
            data = Map<String, dynamic>.from(decoded['data']);
          } else {
            data = Map<String, dynamic>.from(decoded);
          }
        } else {
          data = <String, dynamic>{};
        }

        debugPrint("Fetched profile data in login: $data");

        final raiderProfile = data['raiderProfile'] as Map<String, dynamic>?;
        final userId =
            raiderProfile?['userId']?.toString() ?? data['id']?.toString();
        if (userId != null && userId.isNotEmpty) {
          await SharedPreferencesHelper.saveUserId(userId);
          debugPrint("LOGIN: Saved userId=$userId to SharedPreferences");
        } else {
          debugPrint("LOGIN: No userId found in profile response");
        }

        final raiderId = raiderProfile?['id']?.toString();
        if (raiderId != null && raiderId.isNotEmpty) {
          await SharedPreferencesHelper.saveRaiderId(raiderId);
          debugPrint("LOGIN: Saved raiderId=$raiderId to SharedPreferences");
        } else {
          debugPrint("LOGIN: No raiderId found in profile response");
        }

        rank.value = raiderProfile?['rank'] ?? "BRONZE";
        debugPrint("Rank+++++: $rank");
        return data;
      } else {
        debugPrint("Failed to fetch profile. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("FETCH PROFILE ERROR: $e");
    }

    return null;
  }

  // ===================== SIGNUP =====================
  Future<void> onSignUpContinuePressed() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final referralCode = referralCodeController.text.trim();

    if (name.isEmpty) return showError("Please enter your name");
    if (email.isEmpty) return showError("Please enter your email");
    if (phone.isEmpty) return showError("Please enter phone number");
    if (password.length < 6) return showError("Password must be 6 characters");
    if (password != confirmPassword) {
      return showError("Passwords do not match");
    }

    final fullPhone = "${selectedCountryCode.value}$phone";

    try {
      final res = await AuthService.signUp(
        phone: fullPhone,
        username: name,
        email: email,
        password: password,
        referralCode: referralCode,
      );

      if (res["success"] == true) {
        Get.to(
          () => VerificationScreen(),
          arguments: {"from": "signup", "email": email, "phone": fullPhone},
        );
      } else {
        showError(res["message"] ?? "Signup failed");
      }
    } catch (_) {
      showError("Signup failed");
    }
  }

  void showError(String message) {
    EasyLoading.showError(message);
  }
}
