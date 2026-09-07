// // Unused file
// import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
// import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
// import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
// import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
// import 'package:ZipBee_Driver/features/massage/screen/massage_screen.dart';
// import 'package:ZipBee_Driver/features/proceed_to_destination2/controller/proceed_to_destination_controller.dart';
// import 'package:ZipBee_Driver/proceed_to_destination3/screen/proceed_to_destination3_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// class ProceedToDestinationScreen extends StatelessWidget {
//   final controller = Get.put(ProceedToDestinationController());

//   ProceedToDestinationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double maxDrag = width - 130;
//     double leftGap = 12;

//     void animateBack(ProceedToDestinationController ctrl, double maxDrag) {
//       Future.microtask(() async {
//         while (ctrl.dragX.value > 0) {
//           await Future.delayed(const Duration(milliseconds: 5));
//           ctrl.dragX.value -= 8;
//           if (ctrl.dragX.value < 0) ctrl.dragX.value = 0;
//         }
//       });
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,

//       // ---------------- APP BAR ----------------
//       appBar: AppBar(
//         backgroundColor: AppColors.onboardingIndicatorActive,
//         elevation: 1,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
//           onPressed: Get.back,
//         ),
//         centerTitle: true,
//         title: Text(
//           "Proceed to Destination",
//           style: getTextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//       ),

//       body: Stack(
//         children: [
//           // ---------------- MAP ----------------
//           Positioned.fill(
//             child: Image.asset(ImagePath.trackmap, fit: BoxFit.cover),
//           ),

//           // ---------------- BOTTOM SHEET ----------------
//           DraggableScrollableSheet(
//             initialChildSize: 0.32,
//             minChildSize: 0.32,
//             maxChildSize: 0.86,
//             builder: (context, scrollController) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.1),
//                       blurRadius: 10,
//                       offset: Offset(0, -3),
//                     ),
//                   ],
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 12),
//                       Center(
//                         child: Container(
//                           height: 5,
//                           width: 45,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade400,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 18),

//                       // ---------------- RIDER PROFILE ----------------
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 30,
//                             backgroundImage: AssetImage(ImagePath.profile),
//                           ),
//                           SizedBox(width: 12),
//                           Obx(
//                             () => Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   controller.riderName.value,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 Text(
//                                   "${controller.pastOrders.value} Past Orders",
//                                   style: TextStyle(color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 18),

//                       // ---------------- MESSAGE + CALL ----------------
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 // Get.to(MassageScreen());
//                               },
//                               icon: Icon(Icons.message),
//                               label: Text("Message (1)"),
//                               style: ElevatedButton.styleFrom(
//                                 foregroundColor: Colors.black,
//                                 backgroundColor: Colors.white,
//                                 side: BorderSide(color: Colors.grey.shade300),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                                 padding: EdgeInsets.symmetric(vertical: 6),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 20),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {},
//                               icon: Icon(Icons.call),
//                               label: Text("Call"),
//                               style: ElevatedButton.styleFrom(
//                                 foregroundColor: Colors.black,
//                                 backgroundColor: Colors.white,
//                                 side: BorderSide(color: Colors.grey.shade300),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                                 padding: EdgeInsets.symmetric(vertical: 6),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 20),

//                       // ---------------- STATUS + EXPRESS ----------------
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               "Order Confirmed",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 "EXPRESS",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Icon(Icons.bolt, size: 18, color: Colors.orange),
//                             ],
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 18),

//                       // ---------------- PICKUP LOCATIONS ----------------
//                       Obx(
//                         () => Column(
//                           children: controller.pickupLocations.map((loc) {
//                             return Container(
//                               margin: EdgeInsets.only(bottom: 14),
//                               padding: EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(color: Colors.grey.shade300),
//                               ),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Image.asset(
//                                     loc["isActive"] == true
//                                         ? IconPath.location_blue
//                                         : IconPath.location_red,
//                                     height: 18,
//                                   ),
//                                   SizedBox(width: 10),

//                                   // TEXT AREA
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // ---------- TITLE + TAG ----------
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 loc["title"].toString(),
//                                                 style: getTextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                             ),

//                                             if (loc["tag"] != "")
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                   horizontal: 10,
//                                                   vertical: 3,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.blue.shade50,
//                                                   borderRadius:
//                                                       BorderRadius.circular(6),
//                                                 ),
//                                                 child: Text(
//                                                   loc["tag"].toString(),
//                                                   style: TextStyle(
//                                                     color: Colors.blue,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ),
//                                           ],
//                                         ),

//                                         SizedBox(height: 6),
//                                         Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             // Address text
//                                             Expanded(
//                                               child: Text(
//                                                 loc["address"].toString(),
//                                                 style: TextStyle(fontSize: 13),
//                                               ),
//                                             ),

//                                             // Load time on right (rounded & background)
//                                             if (loc["subTag"] != "")
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                   horizontal: 10,
//                                                   vertical: 3,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.blue.shade50,
//                                                   borderRadius:
//                                                       BorderRadius.circular(6),
//                                                 ),
//                                                 child: Text(
//                                                   loc["subTag"].toString(),
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: Colors.blue,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),

//                       SizedBox(height: 10),

//                       // ---------------- SLIDE BUTTON ----------------
//                       Obx(() {
//                         double progress = (controller.dragX.value / maxDrag)
//                             .clamp(0.0, 1.0);

//                         Color backgroundColor = Color.lerp(
//                           AppColors.onboardingIndicatorActive,
//                           Colors.blue.shade200,
//                           progress,
//                         )!;

//                         double textOpacity = 1.0 - progress;

//                         return Stack(
//                           alignment: Alignment.centerLeft,
//                           children: [
//                             Container(
//                               height: 68,
//                               width: width,
//                               decoration: BoxDecoration(
//                                 color: backgroundColor,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),

//                             // Text
//                             Opacity(
//                               opacity: textOpacity,
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 26),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         SizedBox(width: 54),
//                                         Text(
//                                           "Arrived ",
//                                           style: getTextStyle(
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.w700,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),

//                             // Slider Button
//                             Positioned(
//                               left: controller.dragX.value + leftGap,
//                               top: 12,
//                               bottom: 12,
//                               child: GestureDetector(
//                                 onHorizontalDragUpdate: (details) {
//                                   controller.dragX.value += details.delta.dx;

//                                   if (controller.dragX.value < 0)
//                                     // ignore: curly_braces_in_flow_control_structures
//                                     controller.dragX.value = 0;
//                                   if (controller.dragX.value > maxDrag)
//                                     // ignore: curly_braces_in_flow_control_structures
//                                     controller.dragX.value = maxDrag;
//                                 },

//                                 onHorizontalDragEnd: (details) {
//                                   if (controller.dragX.value >= maxDrag - 5) {
//                                     Get.to(() => ProceedToDestination3Screen());
//                                     Future.delayed(
//                                       Duration(milliseconds: 300),
//                                       () {
//                                         controller.dragX.value = 0;
//                                       },
//                                     );
//                                   } else {
//                                     // Animate back
//                                     animateBack(controller, maxDrag);
//                                   }
//                                 },

//                                 child: Container(
//                                   height: 44,
//                                   width: 56,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Center(
//                                     child: Image.asset(
//                                       IconPath.playicon,
//                                       height: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       }),

//                       SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
