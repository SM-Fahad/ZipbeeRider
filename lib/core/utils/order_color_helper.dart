import 'package:flutter/material.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';

enum OrderCategory {
  current,   // Rank 1 (Yellow #FFCC00)
  later,     // Rank 2 (Blue #3B82F6)
  scheduled, // Rank 3 (Grey #D8D8D8)
}

class OrderColorHelper {
  /// Color definitions based on lifecycle requirements
  static const Color currentYellow = AppColors.primaryButtonColor; // 0xFFFFCC00
  static const Color laterBlue = Color(0xFF3B82F6);                 // 0xFF3B82F6
  static const Color scheduledGrey = AppColors.greyButtonColor;    // 0xFFD8D8D8
  static const Color pastColor = Color(0xFFFFA500);

  /// Utility to parse Hex string (e.g., "#FFB800" or "FFB800") to Flutter Color.
  static Color? parseHexColor(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty) return null;
    String hex = hexString.replaceAll('#', '').trim();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final val = int.tryParse(hex, radix: 16);
    if (val == null) return null;
    return Color(val);
  }

  /// Checks if two DateTimes represent the same calendar date in local time.
  static bool isSameDate(DateTime first, DateTime second) {
    final f = first.toLocal();
    final s = second.toLocal();
    return f.year == s.year && f.month == s.month && f.day == s.day;
  }

  /// Determines the lifecycle category of an order:
  /// - Current (Yellow): ASAP, or Scheduled with collection <= 45 mins away or already in past
  /// - Later (Blue): Scheduled on same day (> 45 mins away, crossed 12:00 AM)
  /// - Scheduled (Grey): Scheduled collection > 1 day away (tomorrow or beyond)
  static OrderCategory getOrderCategory(OrderModel order, {DateTime? currentTime}) {
    final now = (currentTime ?? DateTime.now()).toLocal();
    final collectTime = order.collectTime.toUpperCase();

    // ASAP orders are always Current
    if (collectTime == 'ASAP') {
      return OrderCategory.current;
    }

    // Scheduled orders
    final targetTime = (order.scheduledTime ?? order.placedAt ?? order.createdAt).toLocal();
    final diff = targetTime.difference(now);

    // If target is in the past or <= 45 minutes away -> Current
    if (targetTime.isBefore(now) || diff <= const Duration(minutes: 45)) {
      return OrderCategory.current;
    }

    // Same day (crossed 12:00 AM of collection day, but > 45 mins away) -> Later
    if (isSameDate(now, targetTime)) {
      return OrderCategory.later;
    }

    // Collection is > 1 day away (tomorrow or later) -> Scheduled
    return OrderCategory.scheduled;
  }

  /// Returns numeric rank for sorting:
  /// 1: Current (Yellow)
  /// 2: Later (Blue)
  /// 3: Scheduled (Grey)
  static int getOrderCategoryRank(OrderModel order, {DateTime? currentTime}) {
    final category = getOrderCategory(order, currentTime: currentTime);
    switch (category) {
      case OrderCategory.current:
        return 1;
      case OrderCategory.later:
        return 2;
      case OrderCategory.scheduled:
        return 3;
    }
  }

  /// Returns color for a given category
  static Color getCategoryColor(OrderCategory category) {
    switch (category) {
      case OrderCategory.current:
        return currentYellow;
      case OrderCategory.later:
        return laterBlue;
      case OrderCategory.scheduled:
        return scheduledGrey;
    }
  }

  /// Determines the background color for an order based on dynamic lifecycle rules.
  static Color getOrderBackgroundColor({
    String? collectTime,
    DateTime? scheduledTime,
    DateTime? placedAt,
    DateTime? currentTime,
    Color? defaultColor,
    String? sectionColor,
    String? primarySectionColor,
    OrderModel? order,
  }) {
    if (order != null) {
      return getCategoryColor(getOrderCategory(order, currentTime: currentTime));
    }

    final now = (currentTime ?? DateTime.now()).toLocal();
    final collectTimeVal = collectTime?.toUpperCase() ?? 'ASAP';

    if (collectTimeVal == 'ASAP') {
      return currentYellow;
    }

    final targetTime = (scheduledTime ?? placedAt ?? now).toLocal();
    final diff = targetTime.difference(now);

    if (targetTime.isBefore(now) || diff <= const Duration(minutes: 45)) {
      return currentYellow;
    }

    if (isSameDate(now, targetTime)) {
      return laterBlue;
    }

    return scheduledGrey;
  }
}
