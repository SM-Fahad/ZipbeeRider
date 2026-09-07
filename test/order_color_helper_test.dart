import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderColorHelper Tests', () {
    test('ASAP order color changes when currentTime passes 1 day', () {
      final placedAt = DateTime.parse('2026-07-28T10:00:00.000Z');

      // 1. Current time is 10 hours after placed_at (within 1 day)
      final time1 = DateTime.parse('2026-07-28T20:00:00.000Z');
      final color1 = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'ASAP',
        scheduledTime: null,
        placedAt: placedAt,
        currentTime: time1,
      );
      expect(color1, AppColors.primaryButtonColor);

      // 2. Current time is 25 hours after placed_at (more than 1 day)
      final time2 = DateTime.parse('2026-07-29T11:00:00.000Z');
      final color2 = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'ASAP',
        scheduledTime: null,
        placedAt: placedAt,
        currentTime: time2,
      );
      expect(color2, OrderColorHelper.pastColor);
    });

    test('SCHEDULED order color changes across future, same day, 1h, and past as currentTime progresses', () {
      final scheduledTime = DateTime.parse('2026-07-30T15:00:00.000Z');

      // 1. currentTime is 2 days earlier -> greyButtonColor
      final colorFuture = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime.parse('2026-07-28T10:00:00.000Z'),
      );
      expect(colorFuture, AppColors.greyButtonColor);

      // 2. currentTime is on the same day (3 hours before) -> seconderyButtonColor
      final colorSameDay = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime.parse('2026-07-30T12:00:00.000Z'),
      );
      expect(colorSameDay, AppColors.seconderyButtonColor);

      // 3. currentTime is within 1 hour (30 minutes before) -> primaryButtonColor
      final colorWithin1Hr = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime.parse('2026-07-30T14:30:00.000Z'),
      );
      expect(colorWithin1Hr, AppColors.primaryButtonColor);

      // 4. currentTime is after scheduled_time (past) -> pastColor
      final colorPast = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime.parse('2026-07-30T16:00:00.000Z'),
      );
      expect(colorPast, OrderColorHelper.pastColor);
    });

    test('isSameDate checks local calendar date', () {
      final dt1 = DateTime(2026, 7, 23, 10, 0);
      final dt2 = DateTime(2026, 7, 23, 18, 0);
      final dt3 = DateTime(2026, 7, 28, 10, 0);

      expect(OrderColorHelper.isSameDate(dt1, dt2), isTrue);
      expect(OrderColorHelper.isSameDate(dt1, dt3), isFalse);
    });
  });
}
