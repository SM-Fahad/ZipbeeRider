import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/account/controller/account_controller.dart';
import '../service/incentives_service.dart';
import '../model/incentive_model.dart';
import '../model/incentive_stats_model.dart';

class IncentivesController extends GetxController {
  final IncentivesService _service = IncentivesService();
  late final AccountController _accountController;
  Worker? _rankWorker;

  var currentTier = "".obs;

  var orderTarget = 100.obs;
  var completedOrders = 45.obs;
  var incentiveAmount = 200.obs;
  var bonusPerOrder = 1.00.obs;

  var streakBonusCollected = false.obs;
  var referralBonusCollected = false.obs;
  var peakHourCollected = false.obs;
  var ratingBonusCollected = false.obs;

  var isLoading = false.obs;
  var incentives = <IncentiveModel>[].obs;
  final currentUserId = RxnString();
  var hasError = false.obs;
  var errorMessage = "".obs;
  final collectingIncentiveIds = <int>{}.obs;
  final collectedIncentiveIds = <int>{}.obs;

  // Wallet tracking
  var walletBalance = 0.0.obs;
  var collectedAmount = 0.obs;

  // Stats
  var stats = Rxn<IncentiveStatsModel>();
  var statsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _accountController = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());
    currentTier.value = _accountController.rank.value;
    _rankWorker = ever<String>(_accountController.rank, (rank) {
      currentTier.value = rank;
    });
    _loadCurrentUser();
    fetchStats();
  }

  @override
  void onClose() {
    _rankWorker?.dispose();
    super.onClose();
  }

  Future<void> _loadCurrentUser() async {
    currentUserId.value = await SharedPreferencesHelper.getUserId();
    currentUserId.value ??= await _service.fetchAndSaveCurrentProfileIds();
    await fetchIncentives();
  }

  /// FETCH INCENTIVES FROM API
  Future<void> fetchIncentives() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = "";
      EasyLoading.show(status: 'Loading...');

      final fetchedIncentives = await _service.fetchIncentives();
      incentives.value = fetchedIncentives;
      collectedIncentiveIds
        ..clear()
        ..addAll(
          fetchedIncentives
              .where(
                (incentive) => incentive.isCollectedByUser(currentUserId.value),
              )
              .map((incentive) => incentive.id),
        )
        ..refresh();

      // Update tier and bonus info based on incentives
      _updateIncentiveInfo();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      //Get.snackbar("Error", "Failed to load incentives");
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  /// UPDATE INCENTIVE INFORMATION FROM FETCHED DATA
  void _updateIncentiveInfo() {
    for (var incentive in incentives) {
      if (incentive.type == "REFERRAL" && incentive.isActive) {
        referralBonusCollected.value = false;
        incentiveAmount.value = incentive.incentiveAmount;
      }
    }
  }

  /// FETCH INCENTIVE STATS FROM API
  Future<void> fetchStats() async {
    try {
      statsLoading.value = true;
      final fetchedStats = await _service.fetchIncentiveStats();
      stats.value = fetchedStats;
    } catch (e) {
      //Get.snackbar("Error", "Failed to load stats");
    } finally {
      statsLoading.value = false;
    }
  }

  ///  COLLECT HANDLER
  Future<void> collectBonus({required int incentiveId}) async {
    if (isIncentiveCollected(incentiveId) ||
        isCollectingIncentive(incentiveId)) {
      return;
    }

    try {
      collectingIncentiveIds.add(incentiveId);
      collectingIncentiveIds.refresh();

      final response = await _service.collectIncentive(incentiveId);

      if (response.collectedIncentive.isCollected) {
        collectedIncentiveIds.add(incentiveId);
        collectedIncentiveIds.refresh();

        // Update wallet balance from response
        final totalWallet = response.user['totalWalletBalance'] ?? 0;
        walletBalance.value = totalWallet.toDouble();

        // Track collected amount
        collectedAmount.value = response.collectedIncentive.amount;

        EasyLoading.showSuccess(
          'Incentive collected! +\$${response.collectedIncentive.amount}',
        );

        // Refresh all data after collection
        await Future.delayed(const Duration(milliseconds: 500));
        await fetchIncentives();
        await fetchStats();
      }
    } catch (e) {
      debugPrint(e.toString());

      // Extract error message
      String errorMsg = e.toString().replaceFirst('Exception: ', '');

      EasyLoading.showError(errorMsg);
    } finally {
      collectingIncentiveIds.remove(incentiveId);
      collectingIncentiveIds.refresh();
    }
  }

  bool isCollectingIncentive(int incentiveId) {
    return collectingIncentiveIds.contains(incentiveId);
  }

  bool isIncentiveCollected(int incentiveId, {String? status}) {
    if (collectedIncentiveIds.contains(incentiveId)) {
      return true;
    }

    final incentive = incentives.firstWhereOrNull(
      (item) => item.id == incentiveId,
    );
    if (incentive?.isCollectedByUser(currentUserId.value) == true) {
      return true;
    }

    final normalizedStatus = status?.toUpperCase() ?? '';
    return normalizedStatus == 'COMPLETED' || normalizedStatus == 'COLLECTED';
  }
}
