import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/network_sevice/http_network_client.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ScanAndPayController extends GetxController {
  final httpNetworkClient = HttpNetworkClient();
  final logger = Logger();

  final orderDetail = Rxn<OrderModel>();
  final orderStopId = RxnInt();
  final isLoadingQr = false.obs;
  final qrData = ''.obs;
  final sessionId = ''.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is Map) {
      final order = argument['order'];
      final stopId = argument['orderStopId'];

      if (order is OrderModel) {
        orderDetail.value = order;
      }
      if (stopId is int) {
        orderStopId.value = stopId;
      }
    } else if (argument is OrderModel) {
      orderDetail.value = argument;
    }

    if (orderDetail.value != null) {
      createCheckoutSession();
    } else {
      errorMessage.value = 'Order data not found';
    }
  }

  double get amountMain => orderDetail.value?.totalCostDouble ?? 0.0;

  double get amountExtra => orderDetail.value?.extraCostDouble ?? 0.0;

  double get codAmount {
    final stopId = orderStopId.value;
    if (stopId == null) {
      return 0.0;
    }
    final stops = orderDetail.value?.orderStops;
    if (stops == null) {
      return 0.0;
    }
    for (final stop in stops) {
      if (stop.id == stopId) {
        final stopPayment = stop.payment;
        if (stopPayment != null) {
          return double.tryParse(stopPayment.amount) ?? 0.0;
        }
      }
    }
    return 0.0;
  }

  String get durationText {
    final order = orderDetail.value;
    if (order == null) {
      return '--';
    }

    final pricing = pricingSummary;
    final totalTimeMin = _readInt(pricing, ['totalTimeMin']);
    if (totalTimeMin > 0) {
      return '$totalTimeMin mins';
    }

    final orderMinutes = order.effectiveTotalTimeMinutes;
    return orderMinutes > 0 ? '$orderMinutes mins' : '--';
  }

  Map<String, dynamic> get pricingSummary =>
      orderDetail.value?.pricingSummary ?? const <String, dynamic>{};

  List<Map<String, dynamic>> get perDropBreakdown {
    final rawList = pricingSummary['perDropBreakdown'];
    if (rawList is! List) {
      return const <Map<String, dynamic>>[];
    }
    return rawList.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  Future<void> createCheckoutSession() async {
    final order = orderDetail.value;
    final stopId = orderStopId.value;
    if (order == null || stopId == null || isLoadingQr.value) {
      if (order != null && stopId == null) {
        errorMessage.value = 'Order stop data not found';
      }
      return;
    }

    try {
      isLoadingQr.value = true;
      errorMessage.value = '';

      final response = await httpNetworkClient.postRequest(
        url: ApiEndPoint.walletCheckoutSession,
        body: {'orderId': order.id, 'orderStopId': stopId},
      );
      debugPrint('Order Id for QR code: ${order.id}');
      debugPrint('Order Stop Id for QR code: $stopId');

      if (!response.isSuccess || response.responseData == null) {
        throw Exception(_extractErrorMessage(response.errorMessage));
      }

      final rawBodyMap = response.responseData as Map<dynamic, dynamic>;
      final bodyMap = <String, dynamic>{};
      rawBodyMap.forEach((key, value) {
        bodyMap[key.toString()] = value;
      });
      final rawData = bodyMap['data'];
      final data = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{};

      final checkoutUrl = data['checkoutUrl']?.toString() ?? '';
      final nextSessionId = data['sessionId']?.toString() ?? '';

      if (checkoutUrl.isEmpty) {
        throw Exception('Checkout URL not found');
      }

      qrData.value = checkoutUrl;
      sessionId.value = nextSessionId;
    } catch (e) {
      final message = _cleanError(e);
      errorMessage.value = message;
      logger.e('Failed to create checkout session: $e');
      EasyLoading.showError(message);
    } finally {
      isLoadingQr.value = false;
    }
  }

  String formatAmount(num? value) {
    return value == null ? '0.00' : value.toStringAsFixed(2);
  }

  double readPricingDouble(String key) {
    return _readDouble(pricingSummary, [key]);
  }

  int readPricingInt(String key) {
    return _readInt(pricingSummary, [key]);
  }

  bool readPricingBool(String key) {
    final value = pricingSummary[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  String _extractErrorMessage(Object? source) {
    if (source is Map && source['message'] != null) {
      return source['message'].toString();
    }

    final raw = source?.toString() ?? '';
    if (raw.isEmpty) {
      return 'Failed to create checkout session';
    }

    return raw;
  }

  String _cleanError(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return text;
  }

  double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0.0;
  }

  int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }
}
