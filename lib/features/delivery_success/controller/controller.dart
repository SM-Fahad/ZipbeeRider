import 'package:get/get.dart';

class DeliverySuccessController extends GetxController {
  var score = 10.obs;
  var totalScore = 10.obs;
  var userName = 'Kent'.obs;
  var rating = 0.obs;
  var feedback = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is Map && argument['userName'] != null) {
      userName.value = argument['userName'].toString();
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
