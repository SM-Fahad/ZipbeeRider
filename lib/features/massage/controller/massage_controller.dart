// import 'package:get/get.dart';
// import 'package:flutter/material.dart';

// class MassageController extends GetxController {
//   final TextEditingController messageController = TextEditingController();

//   RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[
//     {
//       "isMe": true,
//       "text":
//           "Hello, Please check your phone, I just booked you to deliver my stuff",
//       "time": "10.10 AM",
//       "date": "24 Aug, 10.10 AM",
//       "isFirstOfDay": true,
//     },
//     {"isMe": false, "text": "Thank you for contacting me.", "time": "10.19 AM"},
//     {
//       "isMe": false,
//       "text": "I am already on my way to the pick up venue.",
//       "time": "10.20 AM",
//     },
//   ].obs;

//   void sendMessage() {
//     if (messageController.text.trim().isEmpty) return;

//     messages.add({
//       "isMe": true,
//       "text": messageController.text.trim(),
//       "time": "Now",
//     });

//     messageController.clear();
//   }
// }
