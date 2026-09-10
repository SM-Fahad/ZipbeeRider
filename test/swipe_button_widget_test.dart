import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scheduled Order Color & Date Label Logic Tests', () {
    test('back-dated scheduled order background color is Current (Yellow)', () {
      final scheduledTime = DateTime.parse('2026-07-23T04:00:00.000Z');
      final placedAt = DateTime.parse('2026-07-22T22:40:37.884Z');

      final color = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        placedAt: placedAt,
      );

      expect(color, AppColors.primaryButtonColor);
    });

    test('isSameDate returns false when comparing current date with past scheduled date', () {
      final now = DateTime.parse('2026-07-28T19:00:00.000Z');
      final scheduledTime = DateTime.parse('2026-07-23T04:00:00.000Z');

      expect(OrderColorHelper.isSameDate(now, scheduledTime), isFalse);
    });
  });
}
