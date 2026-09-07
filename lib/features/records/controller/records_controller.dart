import 'package:ZipBee_Driver/features/cancelled_order/screen/cancelled_order_screen.dart';
import 'package:ZipBee_Driver/features/compleate_orders/screen/complete_orders_screen.dart';
import 'package:ZipBee_Driver/features/records/on_going/screen/on_going_screen.dart';
import 'package:ZipBee_Driver/features/statistics/screen/statistics_screen.dart';
import 'package:get/get.dart';


class RecordsController extends GetxController {
  void goToOnGoing() {
    Get.to(OnGoingScreen());
  }

  void goToCompleted() {
    Get.to(CompleteOrdersScreen());
  }

  void goToCancelled() {
    Get.to(CancelledOrderScreen());
  }

  void goToIncome() {
    Get.to(StatisticsScreen());
  }
}
