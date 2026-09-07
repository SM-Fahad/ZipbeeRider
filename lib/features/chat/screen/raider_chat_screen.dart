import 'package:ZipBee_Driver/core/services/external_launcher_service.dart';
import 'package:ZipBee_Driver/features/chat/controller/raider_chat_controller.dart';
import 'package:ZipBee_Driver/features/chat/widget/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderChatScreen extends StatelessWidget {
  final String receiverId;
  final String? customerName;
  final String? orderId;
  final String? total;
  final String? assignRiderPhone;
  final String? vehicleType;

  RiderChatScreen({
    String? receiverId,
    String? customerName,
    String? orderId,
    String? total,
    String? assignRiderPhone,
    String? vehicleType,
    Key? key,
  }) : receiverId = receiverId ?? _resolveReceiverId(),
       customerName = customerName ?? _resolveCustomerName(),
       orderId = orderId ?? _resolveOrderId(),
       total = total ?? _resolveTotal(),
       assignRiderPhone = assignRiderPhone ?? _resolveAssignRiderPhone(),
       vehicleType = vehicleType ?? _resolveVehicleType(),
       super(key: key);

  final RiderMessageController controller = Get.put(RiderMessageController());

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "receiverId: $receiverId, customerName: $customerName, orderId: $orderId, total: $total",
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              customerName ?? '',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            // const Text(
            //   "Active 2 min ago",
            //   style: TextStyle(color: Colors.grey, fontSize: 12),
            // ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.phone_forwarded_outlined,
              color: Colors.amber,
            ),
            onPressed: () {
              ExternalLauncherService.openDialer(assignRiderPhone ?? '');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (orderId != null && orderId!.isNotEmpty)
            OrderInfoCard(
              orderId: orderId!,
              vehicleType: vehicleType ?? 'UNKNOWN',
              totalCost: (total != null && total!.isNotEmpty)
                  ? (double.tryParse(total!) ?? 0.0)
                  : 0.0,
            ),
          // const Padding(
          //   padding: EdgeInsets.symmetric(vertical: 20),
          //   child: Text(
          //     "24 Aug, 10.10 AM",
          //     style: TextStyle(color: Colors.grey),
          //   ),
          // ),

          /// Messages
          SizedBox(height: 15),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: controller.messages[index]);
                },
              );
            }),
          ),

          /// Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: controller.textController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(receiverId),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                final text = controller.textController.text.trim();
                if (text.isEmpty) return;

                controller.sendMessage(receiverId);

                controller.textController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Resolve receiver id from navigation arguments when not provided directly.
  static String _resolveReceiverId() {
    final args = Get.arguments;

    if (args is Map && args['receiverId'] != null) {
      return args['receiverId'].toString();
    }

    if (args != null) {
      return args.toString();
    }

    return '';
  }

  /// Resolve customer name from navigation arguments when not provided directly.
  static String? _resolveCustomerName() {
    final args = Get.arguments;

    if (args is Map && args['customerName'] != null) {
      return args['customerName'].toString();
    }

    return null;
  }

  /// Resolve order id from navigation arguments when not provided directly.
  static String? _resolveOrderId() {
    final args = Get.arguments;

    if (args is Map && args['orderId'] != null) {
      return args['orderId'].toString();
    }

    return null;
  }

  /// Resolve total from navigation arguments when not provided directly.
  static String? _resolveTotal() {
    final args = Get.arguments;

    if (args is Map && args['total'] != null) {
      return args['total'].toString();
    }

    return null;
  }

  /// Resolve assigned rider phone from navigation arguments when not provided directly.
  static String? _resolveAssignRiderPhone() {
    final args = Get.arguments;

    if (args is Map && args['assignRiderPhone'] != null) {
      return args['assignRiderPhone'].toString();
    }

    return null;
  }

  /// Resolve vehicle type from navigation arguments when not provided directly.
  static String? _resolveVehicleType() {
    final args = Get.arguments;

    if (args is Map && args['vehicleType'] != null) {
      return args['vehicleType'].toString();
    }

    return null;
  }
}

class OrderInfoCard extends StatelessWidget {
  final String orderId;
  final String vehicleType;
  final double totalCost;

  const OrderInfoCard({
    super.key,
    required this.orderId,
    required this.vehicleType,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFBE6), // Light yellowish-white
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order #$orderId",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            "Vehicle type: $vehicleType, Total: \$${totalCost.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
