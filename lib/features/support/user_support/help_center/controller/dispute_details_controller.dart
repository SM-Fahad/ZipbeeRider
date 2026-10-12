import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/controller/create_dispute_appeal_controller.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/screen/create_dispute_appeal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DisputeDetailsController extends GetxController {
  DisputeDetailsController({
    this.disputeId,
    this.orderId,
    Map<String, dynamic>? initialDispute,
  }) {
    if (initialDispute != null) {
      dispute.value = initialDispute;
      _extractAppealFromDispute(initialDispute);
    }
  }

  final int? disputeId;
  final int? orderId;

  final Rxn<Map<String, dynamic>> dispute = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> appeal = Rxn<Map<String, dynamic>>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  int? get resolvedDisputeId {
    if (disputeId != null) return disputeId;
    final idVal = dispute.value?['id'];
    if (idVal is int) return idVal;
    return int.tryParse(idVal?.toString() ?? '');
  }

  int? get resolvedOrderId {
    if (orderId != null) return orderId;
    final idVal = dispute.value?['orderId'];
    if (idVal is int) return idVal;
    return int.tryParse(idVal?.toString() ?? '');
  }

  String get displayOrderNumber {
    final orderObj = dispute.value?['order'];
    if (orderObj is Map) {
      final orderNumber = orderObj['orderNumber']?.toString();
      if (orderNumber != null && orderNumber.isNotEmpty) return orderNumber;
    }
    final rawOrderId = resolvedOrderId;
    if (rawOrderId != null) {
      return 'ORD-${rawOrderId.toString().padLeft(6, '0')}';
    }
    return '-';
  }

  String get formattedDeductionAmount {
    final currentDispute = dispute.value;
    if (currentDispute == null) return '\$0.00';

    final rawAmount = currentDispute['riderAmount'] ??
        currentDispute['refundAmount'] ??
        currentDispute['amount'];

    if (rawAmount == null) return '\$0.00';
    final parsed = double.tryParse(rawAmount.toString());
    if (parsed == null) return '\$$rawAmount';
    return '\$${parsed.toStringAsFixed(2)}';
  }

  bool get canFileAppeal {
    final currentDispute = dispute.value;
    if (currentDispute == null) return false;

    final status = currentDispute['status']?.toString().toUpperCase();
    if (status != 'RESOLVED') return false;

    // If an appeal already exists, cannot file another
    if (appeal.value != null) return false;

    // Check 48 hour window from resolvedAt
    final resolvedAtStr = currentDispute['resolvedAt']?.toString();
    if (resolvedAtStr != null && resolvedAtStr.isNotEmpty) {
      try {
        final resolvedTime = DateTime.parse(resolvedAtStr).toLocal();
        final deadline = resolvedTime.add(const Duration(hours: 48));
        return DateTime.now().isBefore(deadline) ||
            DateTime.now().isAtSameMomentAs(deadline);
      } catch (_) {
        return true;
      }
    }

    return true;
  }

  void _extractAppealFromDispute(Map<String, dynamic> data) {
    final rawAppeals = data['disputeAppeals'];
    if (rawAppeals is List && rawAppeals.isNotEmpty) {
      final first = rawAppeals.first;
      if (first is Map) {
        appeal.value = Map<String, dynamic>.from(first);
      }
    }
  }

  Future<void> fetchDetails({bool showLoader = true}) async {
    try {
      if (showLoader && dispute.value == null) {
        isLoading.value = true;
      }
      errorMessage.value = null;

      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication token not found';
        return;
      }

      // 1. Fetch Dispute by ID if available
      int? targetDisputeId = disputeId ?? resolvedDisputeId;

      if (targetDisputeId != null) {
        final disputeUri = Uri.parse(ApiEndPoint.disputeDetail(targetDisputeId));
        final response = await http.get(
          disputeUri,
          headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            final fetchedDispute =
                Map<String, dynamic>.from(decoded['data'] as Map);
            dispute.value = fetchedDispute;
            _extractAppealFromDispute(fetchedDispute);
          }
        }
      }

      // 2. If dispute is still null and orderId is available, search by orderId
      if (dispute.value == null && orderId != null) {
        final searchUri = Uri.parse(ApiEndPoint.disputeByOrderId(orderId));
        final response = await http.get(
          searchUri,
          headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            final dataField = decoded['data'];
            List items = [];
            if (dataField is Map && dataField['data'] is List) {
              items = dataField['data'] as List;
            } else if (dataField is List) {
              items = dataField;
            }

            if (items.isNotEmpty) {
              final fetchedDispute =
                  Map<String, dynamic>.from(items.first as Map);
              dispute.value = fetchedDispute;
              _extractAppealFromDispute(fetchedDispute);
            }
          }
        }
      }

      // 3. Fetch Appeal separately if not embedded in dispute
      final effectiveId = resolvedDisputeId;
      if (effectiveId != null && appeal.value == null) {
        final appealUri =
            Uri.parse(ApiEndPoint.disputeAppealsByDisputeId(effectiveId));
        final appealResponse = await http.get(
          appealUri,
          headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
        );

        if (appealResponse.statusCode == 200) {
          final decoded = jsonDecode(appealResponse.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            final dataField = decoded['data'];
            List items = [];
            if (dataField is Map && dataField['items'] is List) {
              items = dataField['items'] as List;
            } else if (dataField is List) {
              items = dataField;
            }

            if (items.isNotEmpty) {
              appeal.value = Map<String, dynamic>.from(items.first as Map);
            }
          }
        }
      }

      if (dispute.value == null) {
        errorMessage.value = 'Dispute details not found';
      }
    } catch (e) {
      debugPrint('Error fetching dispute details: $e');
      if (dispute.value == null) {
        errorMessage.value = 'Failed to load dispute details';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openCreateAppeal() async {
    final dId = resolvedDisputeId;
    final oId = resolvedOrderId;

    if (dId == null || oId == null) {
      EasyLoading.showError('Dispute or Order ID is missing');
      return;
    }

    if (Get.isRegistered<CreateDisputeAppealController>()) {
      Get.delete<CreateDisputeAppealController>(force: true);
    }

    final created = await Get.to<bool>(
      () => CreateDisputeAppealScreen(
        orderDisputeId: dId,
        orderId: oId,
      ),
    );

    if (created == true) {
      EasyLoading.showSuccess('Appeal submitted');
      await fetchDetails(showLoader: false);
    }
  }
}
