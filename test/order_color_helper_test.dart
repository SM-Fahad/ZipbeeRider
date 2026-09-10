import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/order_color_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderColorHelper Lifecycle & Sorting Tests', () {
    test('ASAP order is always Current (Yellow)', () {
      final now = DateTime(2026, 9, 10, 12, 0);
      final color = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'ASAP',
        placedAt: DateTime(2026, 9, 10, 11, 30),
        currentTime: now,
      );
      expect(color, AppColors.primaryButtonColor); // #FFCC00
    });

    test('SCHEDULED order transitions: > 1 day (Grey) -> Same Day (Blue) -> <= 45 mins (Yellow)', () {
      final scheduledTime = DateTime(2026, 9, 12, 15, 0); // 2 days in future

      // 1. > 1 day away -> Scheduled (Grey)
      final colorFuture = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime(2026, 9, 10, 10, 0),
      );
      expect(colorFuture, AppColors.greyButtonColor);

      // 2. Same day, 3 hours before (crossed 12:00 AM of collection day, > 45m away) -> Later (Blue)
      final colorSameDay = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime(2026, 9, 12, 12, 0),
      );
      expect(colorSameDay, OrderColorHelper.laterBlue);

      // 3. Collection is 30 to 45 mins away -> Current (Yellow)
      final colorUrgent = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime(2026, 9, 12, 14, 25), // 35 mins before
      );
      expect(colorUrgent, AppColors.primaryButtonColor);

      // 4. Past scheduled time -> Current (Yellow)
      final colorPast = OrderColorHelper.getOrderBackgroundColor(
        collectTime: 'SCHEDULED',
        scheduledTime: scheduledTime,
        currentTime: DateTime(2026, 9, 12, 15, 30),
      );
      expect(colorPast, AppColors.primaryButtonColor);
    });

    test('isSameDate correctly checks local calendar date', () {
      final dt1 = DateTime(2026, 9, 10, 8, 0);
      final dt2 = DateTime(2026, 9, 10, 23, 30);
      final dt3 = DateTime(2026, 9, 11, 0, 1);

      expect(OrderColorHelper.isSameDate(dt1, dt2), isTrue);
      expect(OrderColorHelper.isSameDate(dt1, dt3), isFalse);
    });
  });
}
