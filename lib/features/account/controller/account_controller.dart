import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/api_end_point/api_end_point.dart';
import '../../../core/shared_prefs_service/shared_preference_helper.dart';
import '../../../core/utils/constants/appcolors.dart';
import '../../../core/services/socket_service.dart';
import '../../home/controller/home_controller.dart';

class AccountController extends GetxController {
  var riderName = "".obs;
  var followers = 0.obs;
  var rating = 0.0.obs;
  var location = "".obs;
  var totalBalance = 0.0.obs;
  var driverPhoto = "".obs;
  var rank = "".obs;
  var stripeAccountId = "".obs;
  var rankColor = AppColors.bronzeColor.obs;
  var isAutoPopupEnabled = false.obs;
  var isAutoPopupUpdating = false.obs;
  var orderFeedRefreshRateSeconds = 10.obs;
  var isFeedRefreshRateUpdating = false.obs;

  bool get canShowAutoPopupPermission {
    final currentRank = normalizeRank(rank.value);
    return currentRank == 'GOLD' || currentRank == 'PLATINUM';
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  String normalizeRank(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'SILVER':
        return 'SILVER';
      case 'GOLD':
        return 'GOLD';
      case 'PLATINUM':
        return 'PLATINUM';
      case 'BRONZE':
      default:
        return 'BRONZE';
    }
  }

  Color getRankColor(String rank) {
    switch (normalizeRank(rank)) {
      case 'SILVER':
        return AppColors.silverColor;
      case 'GOLD':
        return AppColors.goldColor;
      case 'PLATINUM':
        return AppColors.platinumColor;
      case 'BRONZE':
      default:
        return AppColors.bronzeColor;
    }
  }

  // ---------------- FETCH PROFILE ----------------
  Future<void> fetchProfile() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final raiderProfile = data['raiderProfile'];
        final registrations = raiderProfile?['registrations'] as List?;

        if (registrations != null && registrations.isNotEmpty) {
          final reg = registrations[0];
          riderName.value = reg['raider_name'] ?? "";
          location.value = reg['current_address'] ?? "";

          final photos = reg['driver_photos'];
          if (photos is List && photos.isNotEmpty) {
            driverPhoto.value = photos.first.toString();
          } else if (photos is String) {
            driverPhoto.value = photos;
          } else {
            driverPhoto.value = "";
          }
        } else {
          riderName.value = "";
          location.value = "";
          driverPhoto.value = "";
        }

        followers.value = data['follower'] ?? 0;
        rating.value = (data['avg_raiderRating'] ?? 0).toDouble();
        totalBalance.value = (data['currentWalletBalance'] ?? 0).toDouble();
        final tier = raiderProfile?['tier'] as Map?;
        rank.value = normalizeRank(tier?['code']?.toString());
        rankColor.value = getRankColor(rank.value);
        isAutoPopupEnabled.value = raiderProfile?['isAutoPopUpEnabled'] == true;
        final savedRate = await SharedPreferencesHelper.getFeedRefreshRate();
        final profileRate = raiderProfile?['orderFeedRefreshRateSeconds'] as int?;
        final finalRate = profileRate ?? savedRate ?? 10;
        orderFeedRefreshRateSeconds.value = finalRate;
        await SharedPreferencesHelper.saveFeedRefreshRate(finalRate);
        stripeAccountId.value =
            data['stripeAccountId'] ?? ""; // Update Stripe Account ID
      } else {
        debugPrint("Failed to fetch profile. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("FETCH PROFILE ERROR: $e");
    }
  }

  Future<bool> updateFeedRefreshRate(int seconds) async {
    if (isFeedRefreshRateUpdating.value) return false;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Access token not found');
        return false;
      }

      isFeedRefreshRateUpdating.value = true;
      final response = await http.patch(
        Uri.parse(ApiEndPoint.feedRefreshRateSettings),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'seconds': seconds}),
      );

      debugPrint("Feed Refresh Rate api response body: ${response.body}");

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final isSuccessfulStatus =
          response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccessfulStatus) {
        final responseMap = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        final data = responseMap?['data'];
        final rate = (data is Map && data['orderFeedRefreshRateSeconds'] is int)
            ? data['orderFeedRefreshRateSeconds'] as int
            : seconds;
        orderFeedRefreshRateSeconds.value = rate;
        await SharedPreferencesHelper.saveFeedRefreshRate(rate);
        return true;
      }

      final message = decoded is Map
          ? decoded['message']?.toString() ?? 'Failed to update feed refresh rate'
          : 'Failed to update feed refresh rate';
      EasyLoading.showError(message);
      return false;
    } catch (e) {
      debugPrint('FEED REFRESH RATE UPDATE ERROR: $e');
      EasyLoading.showError('Failed to update feed refresh rate');
      return false;
    } finally {
      isFeedRefreshRateUpdating.value = false;
    }
  }

  Future<void> updateAutoPopupPermission(bool enabled) async {
    if (isAutoPopupUpdating.value) return;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Access token not found');
        return;
      }

      isAutoPopupUpdating.value = true;
      final response = await http.patch(
        Uri.parse(ApiEndPoint.autoPopupSettings),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'enabled': enabled}),
      );

      debugPrint("Auto Popup api respnse body: ${response.body}");

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final isSuccessfulStatus =
          response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccessfulStatus) {
        final responseMap = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        final updatedValue = responseMap?['isAutoPopUpEnabled'];
        final tier = responseMap?['tier'];

        isAutoPopupEnabled.value =
            updatedValue is bool ? updatedValue : enabled;

        if (tier is Map) {
          rank.value = normalizeRank(tier['code']?.toString());
          rankColor.value = getRankColor(rank.value);
        }
        return;
      }

      final message = decoded is Map
          ? decoded['message']?.toString() ?? 'Failed to update setting'
          : 'Failed to update setting';
      EasyLoading.showError('Error $message');
    } catch (e) {
      debugPrint('AUTO POPUP UPDATE ERROR: $e');
      EasyLoading.showError('Error! Failed to update auto popup permission');
    } finally {
      isAutoPopupUpdating.value = false;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      Get.offAllNamed('/login');

      await http.post(
        Uri.parse(ApiEndPoint.logOut),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } catch (e) {
      debugPrint("LOGOUT ERROR: $e");
    } finally {
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.isOnline.value = false;
        homeCtrl.clearOrdersState();
      }
      SocketService().disconnect();
      await SharedPreferencesHelper.clearAllData();
    }
  }
}
