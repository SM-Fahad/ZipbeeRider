// ignore_for_file: avoid_print

import 'package:get/get.dart';

class QuizCongratulationController extends GetxController {
  var score = 0.obs;
  var totalScore = 0.obs;
  var userName = 'User'.obs;
  var rating = 0.obs;
  var feedback = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get score from arguments passed from quiz screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      score.value = arguments['score'] ?? 0;
      totalScore.value = arguments['totalScore'] ?? 0;
    }
  }

  void updateRating(int value) {
    rating.value = value;
  }

  void updateFeedback(String text) {
    feedback.value = text;
  }

  void submitResult() {
    print('Score: ${score.value}/${totalScore.value}');
    print('Rating: ${rating.value}');
    print('Feedback: ${feedback.value}');
  }
}
