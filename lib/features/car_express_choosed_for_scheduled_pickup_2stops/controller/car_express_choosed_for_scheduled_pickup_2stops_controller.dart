// import 'package:ZipBee_Driver/features/car_express_customer_pending_review/screen/car_express_customer_pending_review_screen.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'dart:math' as math;
// import '../../take_now/model/order_detail_response.dart';
// import '../../take_now/service/order_detail_service.dart';

// class CarExpressChoosedForScheduledPickup2stopsController
//     extends GetxController {
//   var dragX = 0.0.obs;

//   RxDouble sheetHeight = 120.0.obs;
//   final double minHeight = 120;
//   final double maxHeight = 420;

//   RxBool isSheetVisible = true.obs;

//   // Order Detail State
//   var orderDetail = Rx<OrderDetail?>(null);
//   var isLoadingOrder = false.obs;
//   var errorMessage = ''.obs;

//   // Location State
//   var distancesToDestinations = <double>[].obs;
//   var timesToDestinations = <int>[].obs;

//   final orderDetailService = OrderDetailService();
//   final logger = Logger();
  
//   static const double earthRadiusKm = 6371.0;

//   @override
//   void onInit() {
//     super.onInit();
//     // Get order ID from arguments
//     final orderId = Get.arguments as int?;
//     logger.i('CarExpressChoosedForScheduledPickup2stops onInit - orderId: $orderId');
//     if (orderId != null) {
//       fetchOrderDetail(orderId);
//     } else {
//       errorMessage.value = 'Order ID not provided';
//       logger.e('Order ID not provided in arguments');
//     }
//   }

//   Future<void> fetchOrderDetail(int orderId) async {
//     try {
//       isLoadingOrder.value = true;
//       errorMessage.value = '';

//       final response = await orderDetailService.fetchOrderDetail(orderId);

//       if (response.success) {
//         orderDetail.value = response.data;
//         _calculateDistancesToDestinations();
//         logger.i('Order loaded: Order #${response.data.id}');
//       } else {
//         errorMessage.value = response.message;
//         logger.e('Failed to load order: ${response.message}');
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       logger.e('Error fetching order: $e');
//     } finally {
//       isLoadingOrder.value = false;
//     }
//   }

//   /// Calculate distances to all destinations (using a default pickup location)
//   void _calculateDistancesToDestinations() {
//     if (orderDetail.value == null) return;

//     // Default location for now (can be enhanced with user's actual location)
//     const double defaultLat = 23.7777571;
//     const double defaultLon = 90.3961643;

//     final distances = <double>[];
//     final times = <int>[];

//     for (final destination in orderDetail.value!.destinations) {
//       try {
//         final destLat = double.parse(destination.latitude);
//         final destLon = double.parse(destination.longitude);

//         final distance = _calculateDistance(defaultLat, defaultLon, destLat, destLon);
//         final time = _calculateEstimatedTime(distance);

//         distances.add(distance);
//         times.add(time);
//       } catch (e) {
//         logger.w('Error calculating distance: $e');
//         distances.add(0);
//         times.add(0);
//       }
//     }

//     distancesToDestinations.value = distances;
//     timesToDestinations.value = times;
//   }

//   /// Haversine formula to calculate distance between two coordinates
//   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     final double dLat = _degreesToRadians(lat2 - lat1);
//     final double dLon = _degreesToRadians(lon2 - lon1);

//     final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_degreesToRadians(lat1)) *
//             math.cos(_degreesToRadians(lat2)) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);

//     final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     final double distance = earthRadiusKm * c;

//     return double.parse(distance.toStringAsFixed(2));
//   }

//   /// Convert degrees to radians
//   double _degreesToRadians(double degrees) {
//     return degrees * math.pi / 180;
//   }

//   /// Calculate estimated time based on distance and average speed
//   int _calculateEstimatedTime(double distanceKm) {
//     const double averageSpeedKmH = 40; // City average speed
//     final double timeHours = distanceKm / averageSpeedKmH;
//     final int timeMinutes = (timeHours * 60).ceil();
//     return timeMinutes;
//   }

//   /// Get formatted distance and time for a specific destination index
//   String getDistanceAndTimeForDestination(int index) {
//     if (index >= distancesToDestinations.length || index >= timesToDestinations.length) {
//       return 'N/A';
//     }
//     final distance = distancesToDestinations[index];
//     final time = timesToDestinations[index];
//     return '${distance.toStringAsFixed(2)} km | $time min';
//   }

//   /// Get total distance across all destinations
//   String getTotalDistance() {
//     if (distancesToDestinations.isEmpty) {
//       return '0.00 km';
//     }
//     final total = distancesToDestinations.reduce((a, b) => a + b);
//     return '${total.toStringAsFixed(2)} km';
//   }

//   void onSlideComplete() {
//     Get.to(CarExpressCustomerPendingReviewScreen());
//   }

//   void resetSlide() {
//     dragX.value = 0.0;
//   }

//   void onDragUpdate(double delta) {
//     sheetHeight.value += -delta;

//     if (sheetHeight.value < minHeight) sheetHeight.value = minHeight;
//     if (sheetHeight.value > maxHeight) sheetHeight.value = maxHeight;
//   }

//   void onDragEnd() {
//     if (sheetHeight.value < minHeight + 40) {
//       sheetHeight.value = minHeight;
//     } else if (sheetHeight.value > maxHeight * 0.5) {
//       sheetHeight.value = maxHeight;
//     } else {
//       sheetHeight.value = minHeight;
//     }
//   }

//   RxInt dialogStep = 0.obs;

//   void showTakeDialog() {
//     dialogStep.value = 0;

//     Future.delayed(Duration(seconds: 2), () {
//       dialogStep.value = 1;
//     });

//     Future.delayed(Duration(seconds: 4), () {
//       dialogStep.value = 2;
//     });
//   }
// }
