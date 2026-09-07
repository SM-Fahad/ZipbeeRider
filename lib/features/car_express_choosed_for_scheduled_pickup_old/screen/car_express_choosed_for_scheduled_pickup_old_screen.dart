// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
// import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
// import 'package:ZipBee_Driver/core/widget/bottom_price_box.dart';
// import 'package:ZipBee_Driver/core/widget/locationTile.dart';
// import 'package:ZipBee_Driver/core/widget/slide_take_button_widget.dart';
// import 'package:ZipBee_Driver/core/widget/destination_map_widget.dart';

// import '../../../core/common/style/global_text_style.dart';
// import '../controller/car_express_choosed_for_scheduled_pickup_old_controller.dart';
// import '../../home/model/order_feed_response.dart';

// class CarExpressChoosedForScheduledPickupOldScreen extends StatelessWidget {
//   const CarExpressChoosedForScheduledPickupOldScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl =
//         Get.find<CarExpressChoosedForScheduledPickupOldController>();

//     final width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.grey.shade300,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: Get.back,
//         ),
//         title: Obx(() {
//           final order = ctrl.orderDetail.value;
//           final routeType = order?.routeType;
//           return Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Image.asset(
//                   routeType == 'ROUND'
//                       ? IconPath.roundtrip
//                       : routeType == 'ONE_WAY'
//                           ? IconPath.oneway
//                           : IconPath.exparess,
//                   width: 30,
//                   height: 30,
//                   errorBuilder: (context, error, stackTrace) => const Icon(
//                     Icons.local_shipping_outlined,
//                     color: Colors.grey,
//                     size: 30,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Car",
//                     style: getTextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         "EXPRESS",
//                         style: getTextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       const Icon(Icons.flash_on,
//                           color: Colors.orange, size: 18),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           );
//         }),
//       ),

//       // ================= BODY =================
//       body: Obx(() {
//         if (ctrl.isLoadingOrder.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (ctrl.errorMessage.isNotEmpty) {
//           return Center(
//             child: Text(
//               ctrl.errorMessage.value,
//               style: getTextStyle(color: Colors.red),
//             ),
//           );
//         }

//         final order = ctrl.orderDetail.value;
//         if (order == null) {
//           return const Center(child: Text('No order found'));
//         }

//         /// 🔥 IMPORTANT FIX HERE
//         /// Convert → List<Destination>
//         /// Remove null + invalid lat/lng
//         final List<Destination> safeDestinations = order.destinations
//             .whereType<Destination>()
//             .where((d) =>
//                 d.latitude.isNotEmpty &&
//                 d.longitude.isNotEmpty)
//             .toList();

//         return Stack(
//           children: [
//             // ================= MAIN CONTENT =================
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ---------- DESTINATIONS ----------
//                   ...List.generate(safeDestinations.length, (index) { 
//                     final d = safeDestinations[index];
//                     return Padding(
//                       padding: EdgeInsets.only(
//                           bottom:
//                               index == safeDestinations.length - 1 ? 0 : 10),
//                       child: LocationTile(
//                         title: d.address,
//                         subtitle: d.noteToDriver ?? '',
//                         distance: ctrl.getDistanceAndTime(index),
//                         isPickup: index == 0,
//                         pickupIconPath: index == 0
//                             ? IconPath.location_blue
//                             : IconPath.location_gray,
//                         dropoffIconPath: IconPath.location_red,
//                       ),
//                     );
//                   }),

//                   const SizedBox(height: 20),

//                   // ---------- REMARKS ----------
//                   Text(
//                     "Remarks",
//                     style: getTextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     safeDestinations.isNotEmpty
//                         ? (safeDestinations.first.noteToDriver ??
//                             'No remarks')
//                         : 'No remarks',
//                     style: getTextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                     ),
//                   ),

//                   const Spacer(),

//                   // ---------- PRICE ----------
//                    BottomPriceBox(
//                     distance: ctrl.getTotalDistance(),
//                     price: '€${order.totalCost}',
//                     routeType: order.routeType,
//                   ),

//                   const SizedBox(height: 26),

//                   // ---------- SLIDE ----------
//                   SlideToTakeButtonWidget(
//                     ctrl: ctrl,
//                     width: width - 32,
//                     firstColor: AppColors.primaryButtonColor,
//                     secondColor: AppColors.seconderyButtonColor,
//                   ),

//                   const SizedBox(height: 140),
//                 ],
//               ),
//             ),

//             // ================= MAP BOTTOM SHEET =================
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Obx(() {
//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 180),
//                   height: ctrl.sheetHeight.value,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius:
//                         const BorderRadius.vertical(top: Radius.circular(18)),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 8,
//                         offset: Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       GestureDetector(
//                         onVerticalDragUpdate: (d) =>
//                             ctrl.sheetHeight.value -= d.delta.dy,
//                         onVerticalDragEnd: (_) {
//                           if (ctrl.sheetHeight.value <
//                               ctrl.minHeight + 40) {
//                             ctrl.sheetHeight.value = ctrl.minHeight;
//                           } else {
//                             ctrl.sheetHeight.value = ctrl.maxHeight;
//                           }
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           child: Container(
//                             width: 50,
//                             height: 5,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade400,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: DestinationMapWidget(
//                           destinations: safeDestinations, // ✅ FIXED
//                           height: double.infinity,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
