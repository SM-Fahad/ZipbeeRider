// // ignore_for_file: deprecated_member_use

// import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
// import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
// import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
// import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
// import 'package:ZipBee_Driver/features/massage/controller/massage_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// class MassageScreen extends StatelessWidget {
//   final MassageController ctrl = Get.put(MassageController());

//   MassageScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       // ---------- APP BAR ----------
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: InkWell(
//           onTap: () => Get.back(),
//           child: Icon(Icons.arrow_back, color: Colors.black),
//         ),

//         centerTitle: true, // VERY IMPORTANT

//         title: Stack(
//           alignment: Alignment.center,
//           children: [
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundImage: AssetImage(ImagePath.profile),
//                 ),
//                 SizedBox(width: 10),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Harry Johson",
//                       style: getTextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     Text(
//                       "Online",
//                       style: getTextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),

//         actions: [
//           Image.asset(IconPath.call, height: 20, width: 20),
//           SizedBox(width: 20),
//         ],
//       ),

//       // ---------- BODY ----------
//       body: Column(
//         children: [
//           Expanded(
//             child: Obx(
//               () => ListView.builder(
//                 padding: EdgeInsets.all(16),
//                 itemCount: ctrl.messages.length,
//                 itemBuilder: (context, index) {
//                   final msg = ctrl.messages[index];
//                   bool isMe = msg['isMe'];

//                   return Column(
//                     crossAxisAlignment: isMe
//                         ? CrossAxisAlignment.end
//                         : CrossAxisAlignment.start,
//                     children: [
//                       if (msg["isFirstOfDay"] == true)
//                         Center(
//                           child: Padding(
//                             padding: EdgeInsets.only(bottom: 10),
//                             child: Text(
//                               msg["date"],
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),

//                       // ----- MESSAGE BUBBLE -----
//                       Container(
//                         margin: EdgeInsets.symmetric(vertical: 4),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 12,
//                         ),
//                         constraints: BoxConstraints(
//                           maxWidth: MediaQuery.of(context).size.width * 0.75,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isMe
//                               ? AppColors.onboardingIndicatorActive
//                               : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           msg['text'],
//                           style: TextStyle(fontSize: 15),
//                         ),
//                       ),

//                       Padding(
//                         padding: EdgeInsets.only(bottom: 10),
//                         child: Text(
//                           "Seen, ${msg['time']}",
//                           style: TextStyle(
//                             color: Colors.grey.shade500,
//                             fontSize: 11,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),

//           // ---------- MESSAGE INPUT ----------
//           chatInputField(),
//         ],
//       ),
//     );
//   }

//   Widget chatInputField() {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(.05),
//               offset: Offset(0, -1),
//               blurRadius: 4,
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.emoji_emotions_outlined, size: 28),
//             SizedBox(width: 10),

//             // INPUT BOX
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 14),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade400, width: 1.2),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: ctrl.messageController,
//                         decoration: InputDecoration(
//                           hintText: "Enter message",
//                           border: InputBorder.none,
//                         ),
//                         minLines: 1,
//                         maxLines: 4,
//                       ),
//                     ),
//                     Icon(Icons.mic_none, size: 26),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(width: 10),

//             // SEND BUTTON
//             InkWell(
//               onTap: () => ctrl.sendMessage(),
//               child: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 radius: 20,
//                 child: Image.asset(IconPath.send, height: 24, width: 24),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
