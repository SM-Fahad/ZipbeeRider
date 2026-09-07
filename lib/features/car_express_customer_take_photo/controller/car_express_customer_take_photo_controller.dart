// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:logger/logger.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:ZipBee_Driver/core/services/file_upload_service.dart';
// import 'package:ZipBee_Driver/core/services/order_completion_service.dart';

// class CarExpressCustomerTakePhotoController extends GetxController {
//   var riderName = "Harry Johnson".obs;
//   var pastOrders = 32.obs;

//   var pickupLocations = [
//     {
//       "title": "Punggol",
//       "address": "Block 666 Punggol Drive #15-32\nSingapore 828665",
//       "tag": "Arrived at 3:05 PM",
//       "isActive": true,
//       "distance": "",
//       "time": "",
//     },
//   ].obs;

//   RxList<String> selectedImages = <String>[].obs;

//   /// Slider
//   var dragX = 0.0.obs;

//   final ImagePicker picker = ImagePicker();
//   final fileUploadService = FileUploadService();
//   final orderCompletionService = OrderCompletionService();
//   final logger = Logger();

//   // State variables for upload/completion
//   var isUploading = false.obs;
//   var uploadProgress = 0.0.obs;
//   var isCompleting = false.obs;
//   var uploadErrorMessage = ''.obs;

//   // Order data (passed from TakeNowController)
//   var orderId = 0.obs;
//   var stopId = 0.obs;
//   var codAmount = 0.0.obs;
//   var notes = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Get order data from arguments
//     final args = Get.arguments as Map<String, dynamic>?;
//     if (args != null) {
//       orderId.value = args['orderId'] ?? 0;
//       stopId.value = args['stopId'] ?? 0;
//       codAmount.value = args['codAmount'] ?? 0.0;
//       notes.value = args['notes'] ?? '';
//       logger.i(
//         'Initialized with order: ${orderId.value}, stop: ${stopId.value}',
//       );
//     }
//   }

//   Future<void> openCameraFirst() async {
//     final XFile? cameraImage = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 70,
//     );

//     if (cameraImage != null) {
//       selectedImages.add(cameraImage.path);
//     }
//   }

//   Future<void> openGalleryNext() async {
//     final List<XFile>? images = await picker.pickMultiImage(imageQuality: 70);

//     if (images != null && images.isNotEmpty) {
//       selectedImages.addAll(images.map((e) => e.path).toList());
//     }
//   }

//   /// Upload selected images and then complete the order stop
//   Future<void> uploadPhotosAndCompleteOrder() async {
//     try {
//       if (selectedImages.isEmpty) {
//         uploadErrorMessage.value = 'Please select at least one photo';
//         return;
//       }

//       if (stopId.value == 0) {
//         uploadErrorMessage.value = 'Stop ID not found';
//         return;
//       }

//       isUploading.value = true;
//       uploadErrorMessage.value = '';
//       uploadProgress.value = 0.0;

//       logger.i('Starting upload for ${selectedImages.length} images');

//       // Step 1: Upload photos
//       final uploadedUrls = await fileUploadService.uploadFiles(
//         selectedImages.toList(),
//       );
//       logger.i('Successfully uploaded ${uploadedUrls.length} photos');

//       uploadProgress.value = 0.5; // 50% progress after upload

//       // Step 2: Complete the order stop
//       isCompleting.value = true;
//       final response = await orderCompletionService.completeOrderStop(
//         stopId: stopId.value,
//         proofUrls: uploadedUrls,
//         notes: notes.value.isNotEmpty ? notes.value : null,
//         codCollected: codAmount.value > 0 ? codAmount.value : null,
//       );

//       logger.i('Stop completed successfully: $response');
//       uploadProgress.value = 1.0; // 100% progress

//       // Clear state after successful completion
//       selectedImages.clear();
//       notes.value = '';
//       codAmount.value = 0.0;

//       // Show success message and navigate
//       EasyLoading.showSuccess('Order stop completed successfully! 🎉');

//       // Navigate to completion screen or back to home
//       Future.delayed(const Duration(milliseconds: 1500), () {
//         Get.back(); // Go back to previous screen
//       });
//     } catch (e) {
//       logger.e('Error uploading photos or completing order: $e');
//       uploadErrorMessage.value = e.toString();
//       EasyLoading.showError(uploadErrorMessage.value);
//     } finally {
//       isUploading.value = false;
//       isCompleting.value = false;
//     }
//   }

//   void removeImage(int index) {
//     if (index >= 0 && index < selectedImages.length) {
//       selectedImages.removeAt(index);
//     }
//   }
// }
