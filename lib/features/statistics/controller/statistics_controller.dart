import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/network_sevice/http_network_client.dart';
import 'package:ZipBee_Driver/features/statistics/model/earning_summary_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum StatisticsRangeType { daily, weekly, monthly }

class StatisticsChartItem {
  final String key;
  final String label;
  final double value;

  StatisticsChartItem({
    required this.key,
    required this.label,
    required this.value,
  });
}

class StatisticsController extends GetxController {
  final selectedRange = StatisticsRangeType.daily.obs;
  final chartItems = <StatisticsChartItem>[].obs;
  final totalEarning = 0.0.obs;
  final totalTips = 0.0.obs;
  final totalDrivingHours = 0.0.obs;
  final currentBadge = 'BRONZE'.obs;
  final isLoading = false.obs;

  final HttpNetworkClient _httpClient = HttpNetworkClient();

  @override
  void onInit() {
    super.onInit();
    fetchProfileSummary();
    fetchEarningsSummary();
  }

  Future<void> fetchProfileSummary() async {
    try {
      final response = await _httpClient.getRequest(
        url: ApiEndPoint.getProfile,
      );
      if (response.isSuccess && response.responseData != null) {
        final root = Map<String, dynamic>.from(response.responseData as Map);
        final data = root['data'] is Map<String, dynamic>
            ? root['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final raiderProfile = data['raiderProfile'] is Map<String, dynamic>
            ? data['raiderProfile'] as Map<String, dynamic>
            : <String, dynamic>{};

        final tier = raiderProfile['tier'] is Map ? raiderProfile['tier'] as Map : <String, dynamic>{};
        currentBadge.value = normalizeRank(tier['code']?.toString());
        totalTips.value = _toDouble(raiderProfile['completed_orders']) ?? 0.0;
        totalDrivingHours.value = _readFirstDouble([
          raiderProfile['totalDrivingHours'],
          raiderProfile['total_driving_hours'],
          raiderProfile['drivingHours'],
          raiderProfile['driving_hours'],
          data['totalDrivingHours'],
          data['total_driving_hours'],
          data['drivingHours'],
          data['driving_hours'],
        ]);
      }
    } catch (e) {
      debugPrint('Error fetching profile summary: $e');
    }
  }

  Future<void> changeRange(StatisticsRangeType range) async {
    if (selectedRange.value == range) return;
    selectedRange.value = range;
    await fetchEarningsSummary();
  }

  Future<void> fetchEarningsSummary() async {
    try {
      isLoading.value = true;

      final response = await _httpClient.postRequest(
        url: '${ApiEndPoint.earnMoney}?rangeType=${selectedRangeApiValue}',
        body: const <String, dynamic>{},
      );

      if (response.isSuccess && response.responseData != null) {
        final summary = EarningSummary.fromJson(
          Map<String, dynamic>.from(response.responseData as Map),
        );

        totalEarning.value = summary.data.totalEarning;
        chartItems.assignAll(_buildChartItems(summary.data.buckets));
      } else {
        totalEarning.value = 0.0;
        chartItems.assignAll(_buildChartItems(const <EarningBucket>[]));
      }
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
      totalEarning.value = 0.0;
      chartItems.assignAll(_buildChartItems(const <EarningBucket>[]));
    } finally {
      isLoading.value = false;
    }
  }

  String get selectedRangeApiValue {
    switch (selectedRange.value) {
      case StatisticsRangeType.daily:
        return 'daily';
      case StatisticsRangeType.weekly:
        return 'weekly';
      case StatisticsRangeType.monthly:
        return 'monthly';
    }
  }

  List<StatisticsChartItem> _buildChartItems(List<EarningBucket> buckets) {
    final totalsByKey = <String, double>{
      for (final bucket in buckets) bucket.date: bucket.total,
    };

    switch (selectedRange.value) {
      case StatisticsRangeType.daily:
        return _buildDailyItems(totalsByKey);
      case StatisticsRangeType.weekly:
        return _buildWeeklyItems(totalsByKey);
      case StatisticsRangeType.monthly:
        return _buildMonthlyItems(totalsByKey);
    }
  }

  List<StatisticsChartItem> _buildDailyItems(Map<String, double> totalsByKey) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      final key = DateFormat('yyyy-MM-dd').format(date);
      return StatisticsChartItem(
        key: key,
        label: DateFormat('dd MMM').format(date),
        value: totalsByKey[key] ?? 0.0,
      );
    });
  }

  List<StatisticsChartItem> _buildWeeklyItems(Map<String, double> totalsByKey) {
    final now = DateTime.now();
    final startOfCurrentWeek = _startOfWeek(now);
    return List.generate(6, (index) {
      final weekStart = startOfCurrentWeek.subtract(Duration(days: 7 * index));
      final key = DateFormat('yyyy-MM-dd').format(weekStart);
      return StatisticsChartItem(
        key: key,
        label: index == 0
            ? 'This Week\n${DateFormat('dd MMM').format(weekStart)}'
            : DateFormat('dd MMM').format(weekStart),
        value: totalsByKey[key] ?? 0.0,
      );
    });
  }

  List<StatisticsChartItem> _buildMonthlyItems(
    Map<String, double> totalsByKey,
  ) {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final date = DateTime(now.year, now.month - index, 1);
      final key = '${date.year}-${date.month}';
      return StatisticsChartItem(
        key: key,
        label: DateFormat('MMM').format(date),
        value: totalsByKey[key] ?? 0.0,
      );
    });
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  double get maxChartValue {
    if (chartItems.isEmpty) return 10;
    final max = chartItems
        .map((item) => item.value)
        .reduce((a, b) => a > b ? a : b);
    return max <= 0 ? 10 : max * 1.2;
  }

  String formatAmount(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String get rangeTitle {
    switch (selectedRange.value) {
      case StatisticsRangeType.daily:
        return 'Daily Earnings';
      case StatisticsRangeType.weekly:
        return 'Weekly Earnings';
      case StatisticsRangeType.monthly:
        return 'Monthly Earnings';
    }
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

  double _readFirstDouble(List<dynamic> values) {
    for (final value in values) {
      final parsed = _toDouble(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
