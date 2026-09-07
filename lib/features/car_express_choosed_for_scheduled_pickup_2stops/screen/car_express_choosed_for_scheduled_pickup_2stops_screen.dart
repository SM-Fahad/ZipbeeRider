// import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
// import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
// import 'package:ZipBee_Driver/core/widget/destination_map_widget.dart';
// import 'package:ZipBee_Driver/features/car_express_choosed_for_scheduled_pickup_2stops/controller/car_express_choosed_for_scheduled_pickup_2stops_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// import '../../../core/common/style/global_text_style.dart' show getTextStyle;
// import '../../../core/widget/bottom_price_box.dart';
// import '../../../core/widget/locationTile.dart';
// import '../../../core/widget/slide_take_button_widget.dart';

// class CarExpressChoosedForScheduledPickup2stopsScreen extends StatelessWidget {
//   const CarExpressChoosedForScheduledPickup2stopsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.put(CarExpressChoosedForScheduledPickup2stopsController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.onboardingIndicatorActive,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: Obx(() {
//           final order = ctrl.orderDetail.value;
//           final routeType = order?.routeType;
//           return Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
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
//               SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Car",
//                     style: getTextStyle(
//                       fontSize: 14,
//                       color: Colors.black,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         "EXPRESS",
//                         style: getTextStyle(
//                           fontSize: 16,
//                           color: Colors.black,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       SizedBox(width: 4),
//                       Icon(Icons.flash_on, color: Colors.orange, size: 18),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           );
//         }),
//       ),

//       body: Obx(() {
//         if (ctrl.isLoadingOrder.value) {
//           return Center(child: CircularProgressIndicator());
//         }

//         if (ctrl.errorMessage.isNotEmpty) {
//           return Center(
//             child: Text('Error: ${ctrl.errorMessage.value}'),
//           );
//         }

//         if (ctrl.orderDetail.value == null) {
//           return Center(child: Text('No order details'));
//         }

//         final order = ctrl.orderDetail.value!;
//         final width = MediaQuery.of(context).size.width - 32;

//         return Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Display all destinations
//                   ...List.generate(
//                     order.destinations.length,
//                     (index) {
//                       final destination = order.destinations[index];
//                       return Column(
//                         children: [
//                           LocationTile(
//                             title: destination.address,
//                             subtitle: destination.floorUnit,
//                             distance: ctrl.getDistanceAndTimeForDestination(index),
//                             isPickup: index == 0,
//                             pickupIconPath: index == 0 ? IconPath.location_blue : IconPath.location_gray,
//                             dropoffIconPath: IconPath.location_gray,
//                           ),
//                           if (index < order.destinations.length - 1)
//                             SizedBox(height: 10),
//                         ],
//                       );
//                     },
//                   ),

//                   SizedBox(height: 20),

//                   Text(
//                     "Remarks:",
//                     style: getTextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),

//                   SizedBox(height: 6),

//                   Text(
//                     order.destinations.isNotEmpty 
//                       ? (order.destinations.first.noteToDriver ?? 'No remarks')
//                       : 'No remarks',
//                     style: getTextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                     ),
//                   ),

//                   Spacer(),

//                   BottomPriceBox(
//                     distance: ctrl.getTotalDistance(),
//                     price: '€${order.totalCost}',
//                     routeType: order.routeType,
//                   ),
//                   SizedBox(height: 26),

//                   SlideToTakeButtonWidget(
//                     ctrl: ctrl,
//                     width: width,
//                     firstColor: AppColors.primaryButtonColor,
//                     secondColor: AppColors.seconderyButtonColor,
//                   ),

//                   SizedBox(height: 140),
//                 ],
//               ),
//             ),

//             Obx(() {
//             return Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 180),
//                 height: ctrl.sheetHeight.value,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(18),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 8,
//                       spreadRadius: 2,
//                       offset: Offset(0, -2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onVerticalDragUpdate: (details) {
//                         ctrl.onDragUpdate(details.delta.dy);
//                       },
//                       onVerticalDragEnd: (_) => ctrl.onDragEnd(),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                         width: double.infinity,
//                         color: Colors.transparent,
//                         child: Center(
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
//                     ),
//                     Expanded(
//                       child: DestinationMapWidget(
//                         destinations: order.destinations as dynamic,
//                         height: double.infinity,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//             }),
//         ],
//       );
//       }),
//     );
//   }
// }
