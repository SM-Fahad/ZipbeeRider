// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'dart:math' as math;
// import '../../take_now/model/order_detail_response.dart';
// import '../../take_now/service/order_detail_service.dart';

// class CarExpressChoosedForScheduledPickupOldController extends GetxController {
//   final logger = Logger();

//   // Sheet
//   RxDouble sheetHeight = 120.0.obs;
//   final double minHeight = 120;
//   final double maxHeight = 420;

//   // Order
//   final orderDetail = Rx<OrderDetail?>(null);
//   final isLoadingOrder = false.obs;
//   final errorMessage = ''.obs;

//   // Distance
//   final distancesToDestinations = <double>[].obs;
//   final timesToDestinations = <int>[].obs;

//   final dialogStep = 0.obs;

//   final OrderDetailService orderDetailService = OrderDetailService();

//   static const double earthRadiusKm = 6371.0;

//   @override
//   void onInit() {
//     super.onInit();
//     final orderId = Get.arguments as int?;
//     if (orderId != null) {
//       fetchOrderDetail(orderId);
//     } else {
//       errorMessage.value = 'Order ID not found';
//     }
//   }

//   Future<void> fetchOrderDetail(int orderId) async {
//     try {
//       isLoadingOrder(true);
//       final response = await orderDetailService.fetchOrderDetail(orderId);

//       if (response.success) {
//         orderDetail.value = response.data;
//         _calculateDistances();
//       } else {
//         errorMessage.value = response.message;
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//     } finally {
//       isLoadingOrder(false);
//     }
//   }

//   void _calculateDistances() {
//     const double startLat = 23.7777571;
//     const double startLon = 90.3961643;

//     final dists = <double>[];
//     final times = <int>[];

//     for (final d in orderDetail.value!.destinations) {
//       try {
//         final lat = double.tryParse(d.latitude);
//         final lon = double.tryParse(d.longitude);

//         if (lat == null || lon == null) {
//           dists.add(0);
//           times.add(0);
//           continue;
//         }

//         final distance = _distance(startLat, startLon, lat, lon);
//         dists.add(distance);
//         times.add(_estimateTime(distance));
//       } catch (_) {
//         dists.add(0);
//         times.add(0);
//       }
//     }

//     distancesToDestinations.value = dists;
//     timesToDestinations.value = times;
//   }

//   double _distance(double lat1, double lon1, double lat2, double lon2) {
//     final dLat = _toRad(lat2 - lat1);
//     final dLon = _toRad(lon2 - lon1);

//     final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_toRad(lat1)) *
//             math.cos(_toRad(lat2)) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);

//     final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     return double.parse((earthRadiusKm * c).toStringAsFixed(2));
//   }

//   double _toRad(double deg) => deg * math.pi / 180;

//   int _estimateTime(double km) => ((km / 40) * 60).ceil();

//   String getDistanceAndTime(int index) {
//     if (index >= distancesToDestinations.length) return 'N/A';
//     return '${distancesToDestinations[index]} km | ${timesToDestinations[index]} min';
//   }

//   String getTotalDistance() {
//     if (distancesToDestinations.isEmpty) return '0.00 km';
//     return '${distancesToDestinations.reduce((a, b) => a + b).toStringAsFixed(2)} km';
//   }

//   // ---------------- ACCEPT ORDER ----------------

//   void onSlideComplete() {
//     dialogStep.value = 0;
//     Get.dialog(_dialog(), barrierDismissible: false);
//     _acceptOrder();
//   }

//   Future<void> _acceptOrder() async {
//     try {
//       dialogStep.value = 1;

//       final id = orderDetail.value?.id;
//       if (id == null) throw 'Order ID missing';

//       final res = await orderDetailService.acceptOrderCompetition(id);

//       if (res['success'] == true) {
//         dialogStep.value = 2;
//         await Future.delayed(const Duration(milliseconds: 1200));
//         Get.back(); // dialog
//         Get.back(); // screen
//         EasyLoading.showSuccess('Order accepted');
//       } else {
//         throw res['message'];
//       }
//     } catch (e) {
//       Get.back();
//       EasyLoading.showError(e.toString());
//     }
//   }

//   Widget _dialog() {
//     return Obx(() {
//       if (dialogStep.value == 0) {
//         return _dialogBox(const CircularProgressIndicator(), 'Processing...');
//       }
//       if (dialogStep.value == 1) {
//         return _dialogBox(const Icon(Icons.info, size: 40), 'Finalizing...');
//       }
//       return _dialogBox(
//           const Icon(Icons.check_circle, size: 55, color: Colors.green),
//           'Success!');
//     });
//   }

//   Widget _dialogBox(Widget icon, String title) {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         width: 300,
//         decoration: BoxDecoration(
//             color: Colors.white, borderRadius: BorderRadius.circular(14)),
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           icon,
//           const SizedBox(height: 14),
//           Text(title, style: const TextStyle(fontSize: 18)),
//         ]),
//       ),
//     );
//   }
// }
