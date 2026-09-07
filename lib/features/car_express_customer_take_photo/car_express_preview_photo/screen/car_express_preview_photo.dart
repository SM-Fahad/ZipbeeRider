// import 'dart:io';
// import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
// import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
// import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
// import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
// import 'package:ZipBee_Driver/features/car_express_customer_pending_review/controller/car_express_customer_pending_review_controller.dart';
// import 'package:ZipBee_Driver/features/car_express_customer_take_photo/controller/car_express_customer_take_photo_controller.dart';
// import 'package:ZipBee_Driver/features/massage/screen/massage_screen.dart';
// import 'package:ZipBee_Driver/features/proceed_to_destination1/screen/proceed_to_load_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CarExpressPreviewPhoto extends StatelessWidget {
//   final photoCtrl = Get.find<CarExpressCustomerTakePhotoController>();
//   final pendingCtrl = Get.put(CarExpressCustomerPendingReviewController());

//   CarExpressPreviewPhoto({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double maxDrag = width - 100;
//     double leftGap = 10;

//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: AppColors.onboardingIndicatorActive,
//         elevation: 0,
//         leading: InkWell(
//           onTap: () => Get.back(),
//           child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//         ),
//         centerTitle: true,
//         title: Text(
//           "Punggol Blk 665",
//           style: getTextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//       ),

//       body: Stack(
//         children: [
//           // ---------------- MAIN CONTENT ----------------
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // TITLE BAR
//                 Container(
//                   width: 375,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 4,
//                     horizontal: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade400,
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withAlpha(10),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Pick Up Item’s',
//                       textAlign: TextAlign.center,
//                       style: getTextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 20),

//                 // IMAGE GRID
//                 Expanded(
//                   child: Obx(
//                     () => GridView.builder(
//                       itemCount: photoCtrl.selectedImages.length,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 1,
//                         crossAxisSpacing: 12,
//                         mainAxisSpacing: 12,
//                       ),
//                       itemBuilder: (context, index) {
//                         return Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.file(
//                                 File(photoCtrl.selectedImages[index]),
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),

//                             // REMOVE BUTTON
//                             Positioned(
//                               right: 6,
//                               top: 6,
//                               child: InkWell(
//                                 onTap: () {
//                                   photoCtrl.selectedImages.removeAt(index);
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withValues(alpha: 0.6),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.close,
//                                     color: Colors.white,
//                                     size: 18,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 140),
//               ],
//             ),
//           ),

//           // ---------------- PERMANENT BOTTOM SHEET ----------------
//           DraggableScrollableSheet(
//             initialChildSize: 0.32,
//             minChildSize: 0.20,
//             maxChildSize: 0.60,
//             builder: (context, scrollController) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(22),
//                   ),
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
//                                   pendingCtrl.riderName.value,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 Text(
//                                   "${pendingCtrl.pastOrders.value} Past Orders",
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
//                             padding: const EdgeInsets.symmetric(
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
//                           children: pendingCtrl.pickupLocations
//                               .where(
//                                 (loc) => loc["isActive"] == true,
//                               ) // <-- Only active location
//                               .map((loc) {
//                                 return Container(
//                                   margin: EdgeInsets.only(bottom: 14),
//                                   padding: EdgeInsets.all(14),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: Colors.grey.shade300,
//                                     ),
//                                   ),
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Image.asset(
//                                         IconPath.location_blue,
//                                         height: 18,
//                                       ),
//                                       SizedBox(width: 10),

//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     loc["title"].toString(),
//                                                     style: getTextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),

//                                                 if (loc["tag"] != "")
//                                                   Container(
//                                                     padding:
//                                                         EdgeInsets.symmetric(
//                                                           horizontal: 10,
//                                                           vertical: 3,
//                                                         ),
//                                                     decoration: BoxDecoration(
//                                                       color:
//                                                           Colors.blue.shade50,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             6,
//                                                           ),
//                                                     ),
//                                                     child: Text(
//                                                       loc["tag"].toString(),
//                                                       style: TextStyle(
//                                                         color: Colors.blue,
//                                                         fontSize: 12,
//                                                       ),
//                                                     ),
//                                                   ),
//                                               ],
//                                             ),

//                                             SizedBox(height: 6),
//                                             Text(loc["address"].toString()),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               })
//                               .toList(),
//                         ),
//                       ),

//                       SizedBox(height: 10),

//                       // ---------------- SLIDE BUTTON ----------------
//                       Obx(() {
//                         double progress = (pendingCtrl.dragX.value / maxDrag)
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

//                             // SLIDE TEXT
//                             Opacity(
//                               opacity: textOpacity,
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 26),
//                                 child: Row(
//                                   children: [
//                                     SizedBox(width: 54),
//                                     Text(
//                                       "Take photo’s",
//                                       style: getTextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),

//                             // SLIDER BUTTON
//                             Positioned(
//                               left: pendingCtrl.dragX.value + leftGap,
//                               top: 12,
//                               bottom: 12,
//                               child: GestureDetector(
//                                 onHorizontalDragUpdate: (details) {
//                                   pendingCtrl.dragX.value += details.delta.dx;

//                                   if (pendingCtrl.dragX.value < 0) {
//                                     pendingCtrl.dragX.value = 0;
//                                   }
//                                   if (pendingCtrl.dragX.value > maxDrag) {
//                                     pendingCtrl.dragX.value = maxDrag;
//                                   }
//                                 },

//                                 onHorizontalDragEnd: (details) async {
//                                   if (pendingCtrl.dragX.value >= maxDrag - 5) {
//                                     // Correct way to call Future.delayed
//                                     Future.delayed(
//                                       Duration(milliseconds: 300),
//                                       () {
//                                         Get.to(() => ProceedToLoadScreen());
//                                         pendingCtrl.dragX.value = 0;
//                                       },
//                                     );
//                                   } else {
//                                     pendingCtrl.dragX.value = 0;
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

//                       SizedBox(height: 30),
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
