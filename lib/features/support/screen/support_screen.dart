// import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
// import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
// import 'package:ZipBee_Driver/features/support/controller/support_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// class SupportScreen extends StatelessWidget {
//   final SupportController controller = Get.put(SupportController());
//
//   SupportScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(56),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 // ignore: deprecated_member_use
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 8,
//                 offset: Offset(0, 3),
//               ),
//             ],
//           ),
//           child: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             centerTitle: true,
//             automaticallyImplyLeading: false,
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
//               onPressed: Get.back,
//             ),
//             title: Text(
//               "Support",
//               style: getTextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ),
//
//       body: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
//             margin: EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Hi Daniel, good day! How may\nI help you today?",
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontSize: 15,
//                     height: 1.4,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   "You may want to ask:",
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 faqItem("How I speed up my parcel delivery?"),
//                 faqItem("What if I confirmed on the wrong order?"),
//                 faqItem("How do I raise a return/ refund request?"),
//                 faqItem("Other Frequently Asked Questions?"),
//               ],
//             ),
//           ),
//
//           // Messages (if you want later)
//           Expanded(
//             child: Obx(
//               () => ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 itemCount: controller.messages.length,
//                 itemBuilder: (context, index) {
//                   return Align(
//                     alignment: Alignment.centerRight,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       margin: EdgeInsets.only(bottom: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(controller.messages[index]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           // Message input box
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(top: BorderSide(color: Colors.grey.shade300)),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                       boxShadow: [
//                         BoxShadow(
//                           // ignore: deprecated_member_use
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 10,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: controller.messageController,
//                             decoration: InputDecoration(
//                               hintText: "Type a message",
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//
//                         /// 👉 Send button INSIDE box
//                         GestureDetector(
//                           onTap: controller.sendMessage,
//                           child: Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(shape: BoxShape.circle),
//                             child: Image.asset(
//                               IconPath.send,
//                               height: 22,
//                               width: 22,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
//
//   Widget faqItem(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("• ", style: TextStyle(fontSize: 16)),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 14.5,
//                 color: Colors.black87,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
