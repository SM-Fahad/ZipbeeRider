// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import '../../take_now/model/order_detail_response.dart';
// import '../../take_now/service/order_detail_service.dart';

// import '../../car_express_customer_pending_review/screen/car_express_customer_pending_review_screen.dart';

// class CarExpressChoosedForScheduledPickupController extends GetxController {
//   var dragX = 0.0.obs;

//   /// Draggable Map Sheet
//   RxDouble sheetHeight = 120.0.obs;
//   final double minHeight = 120;
//   final double maxHeight = 420;

//   RxBool isSheetVisible = true.obs;

//   // Order Detail State
//   var orderDetail = Rx<OrderDetail?>(null);
//   var isLoadingOrder = false.obs;
//   var errorMessage = ''.obs;

//   final orderDetailService = OrderDetailService();
//   final logger = Logger();

//   @override
//   void onInit() {
//     super.onInit();
//     // Get order ID from arguments
//     final orderId = Get.arguments as int?;
//     logger.i('CarExpressChoosedForScheduledPickup onInit - orderId: $orderId');
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

//   void onSlideComplete() {
//     Get.to(CarExpressCustomerPendingReviewScreen());
//   }
//   void resetSlide() {
//     dragX.value = 0.0;
//   }

//   /// —— DRAGGABLE SHEET LOGIC ——
//   void onDragUpdate(double delta) {
//     sheetHeight.value += -delta;

//     if (sheetHeight.value < minHeight) sheetHeight.value = minHeight;
//     if (sheetHeight.value > maxHeight) sheetHeight.value = maxHeight;
//   }

//   void onDragEnd() {
//     if (sheetHeight.value < minHeight + 40) {
//       sheetHeight.value = minHeight; // collapse only, don't hide
//     } else if (sheetHeight.value > maxHeight * 0.5) {
//       sheetHeight.value = maxHeight; // expand fully
//     } else {
//       sheetHeight.value = minHeight;
//     }
//   }

//   /// —— DIALOG STEPS ——
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
