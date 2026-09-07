import 'package:flutter/material.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/home/model/order_model.dart';

class OrderColorHelper {
  /// Color used when date/time is already in the past.
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

  /// Determines the background color for an order.
  /// NEW LOGIC: Uses dynamic "sectionColor" / "primarySectionColor" (from feedMeta or order JSON).
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
    // =========================================================================
    // NEW DYNAMIC COLOR LOGIC USING sectionColor / primarySectionColor FROM feedMeta
    // =========================================================================
    final hexString = sectionColor ??
        primarySectionColor ??
        order?.sectionColor ??
        order?.primarySectionColor;

    final parsedColor = parseHexColor(hexString);
    if (parsedColor != null) {
      return parsedColor;
    }

    return defaultColor ?? AppColors.primaryButtonColor;

    /*
    // =========================================================================
    // OLD COLOR LOGIC (COMMENTED OUT AS REQUESTED BY USER)
    // =========================================================================
    final collectTimeVal = collectTime?.toUpperCase();
    final now = (currentTime ?? DateTime.now()).toLocal();

    // LOGIC 1: ASAP ORDER COLOR CALCULATION /
    if (collectTimeVal == 'ASAP') {
      // For ASAP, check placed_at time (fallback to scheduledTime if placedAt is null)
      final timeToCheck = placedAt?.toLocal() ?? scheduledTime?.toLocal();
      if (timeToCheck == null) {
        return defaultColor ?? AppColors.primaryButtonColor;  // 0xFFFFCC00
      }

      // If placed_at is more than 1 day (24 hours) older than current time -> pastColor
      if (now.difference(timeToCheck) >= const Duration(days: 1)) {
        return pastColor; // 0xFFFFA500
      }

      // Otherwise (within 1 day) -> primaryButtonColor
      return AppColors.primaryButtonColor; // 0xFFFFCC00
    }

    // LOGIC 2: SCHEDULED ORDER COLOR CALCULATION
    // For SCHEDULED, check scheduled_time (fallback to placedAt if scheduledTime is null)
    final scheduledTarget = scheduledTime?.toLocal() ?? placedAt?.toLocal();
    if (scheduledTarget == null) {
      return defaultColor ?? AppColors.primaryButtonColor;
    }

    // 2a. If scheduled_time is in the past -> pastColor (#FFA500)
    if (scheduledTarget.isBefore(now)) {
      return pastColor; // 0xFFFFA500
    }

    // 2b. If scheduled_time is within 1 hour from current time -> primaryButtonColor
    final diff = scheduledTarget.difference(now);
    if (diff <= const Duration(hours: 1)) {
      return AppColors.primaryButtonColor; // 0xFFFFCC00
    }

    // 2c. If scheduled_time date is the same as current date -> seconderyButtonColor
    if (isSameDate(now, scheduledTarget)) {
      return AppColors.seconderyButtonColor; // 0xFF6DB1E0
    }

    // 2d. If scheduled_time is tomorrow or further in the future -> greyButtonColor
    return AppColors.greyButtonColor; // 0xFFD8D8D8
    */
  }
}
