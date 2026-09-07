import 'dart:ui';

import 'package:get/get.dart';

class TryAginController extends GetxController {
  var score = '0/0'.obs;
  var message = 'Please try again'.obs;

  @override
  void onInit() {
    super.onInit();
    // Get score from arguments passed from quiz screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      score.value = arguments['score'] ?? '0/0';
    }
  }

  VoidCallback? get tryAgain => null;
}
