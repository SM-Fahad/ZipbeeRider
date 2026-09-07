// import 'package:flutter/material.dart';

// class OrderInfoCard extends StatelessWidget {
//   final String orderId;
//   final String pickupDateTime;
//   final String fromName;
//   final String toName;
//   final String vehicleType;
//   final String totalAmount;
//   final Color? backgroundColor;

//   const OrderInfoCard({
//     super.key,
//     required this.orderId,
//     required this.pickupDateTime,
//     required this.fromName,
//     required this.toName,
//     required this.vehicleType,
//     required this.totalAmount,
//     this.backgroundColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: backgroundColor ?? const Color(0xFFFFFBE6),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Order #$orderId , $pickupDateTime",
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 13,
//             ),
//           ),
//           // const SizedBox(height: 8),
//           // Text(
//           //   "From $fromName → $toName",
//           //   style: TextStyle(
//           //     color: Colors.grey[700],
//           //     fontSize: 13,
//           //   ),
//           // ),
//           const SizedBox(height: 4),
//           Text(
//             "Vehicle type: $vehicleType, Total: $totalAmount",
//             style: TextStyle(
//               color: Colors.grey[700],
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
