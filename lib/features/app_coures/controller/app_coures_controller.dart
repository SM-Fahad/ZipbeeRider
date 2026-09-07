import 'package:ZipBee_Driver/features/app_quzi/controller/app_quiz_controller.dart';
import 'package:ZipBee_Driver/features/app_quzi/model/question_model.dart';
import 'package:ZipBee_Driver/features/app_quzi/service/quiz_service.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AppCouresController extends GetxController {
  // Observables
  var currentIndex = 0.obs;
  var selectedOption = ''.obs;
  var selectedOptions = <String>[].obs; // store answers for all questions
  var questions = <Map<String, dynamic>>[].obs; // Questions from API
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var lastQuizId = 0.obs; // Track which quiz's questions we're viewing

  final logger = Logger();
  final quizService = QuizService();

  @override
  void onInit() {
    super.onInit();
    _loadQuestions();
  }

  /// Load questions from AppQuizController or fetch again if not available
  void _loadQuestions() async {
    try {
      isLoading.value = true;

      // Try to get AppQuizController
      AppQuizController? quizCtrl;
      try {
        quizCtrl = Get.find<AppQuizController>();
      } catch (e) {
        // AppQuizController not found, will fetch quiz and questions from API
        logger.w('AppQuizController not found, fetching from API');
        quizCtrl = null;
      }

      // If we have the controller and quiz data
      if (quizCtrl != null && quizCtrl.quiz.value != null) {
        final currentQuizId = quizCtrl.quiz.value!.id;

        // If different quiz, reset selections
        if (lastQuizId.value != currentQuizId) {
          currentIndex.value = 0;
          selectedOption.value = '';
          selectedOptions.clear();
          lastQuizId.value = currentQuizId;
        }

        // Convert QuestionModel list to format expected by screen
        final convertedQuestions = _convertQuestionsToMap(quizCtrl.questions);

        if (convertedQuestions.isEmpty) {
          throw Exception('No questions available for this quiz.');
        }

        questions.value = convertedQuestions;
        errorMessage.value = '';
        logger.i('Loaded ${questions.length} questions from controller');
      } else {
        // Controller not available, fetch from API
        logger.i('Fetching quiz and questions from API');
        
        final quiz = await quizService.fetchActiveQuiz();
        final questionsList = await quizService.fetchQuizQuestions(quiz.id);

        if (questionsList.isEmpty) {
          throw Exception('No questions available for this quiz.');
        }

        final currentQuizId = quiz.id;

        // Reset selections for new quiz
        if (lastQuizId.value != currentQuizId) {
          currentIndex.value = 0;
          selectedOption.value = '';
          selectedOptions.clear();
          lastQuizId.value = currentQuizId;
        }

        // Convert questions to format expected by screen
        final convertedQuestions = _convertQuestionsToMap(questionsList);
        questions.value = convertedQuestions;
        errorMessage.value = '';
        logger.i('Loaded ${questions.length} questions from API');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      logger.e('Error loading questions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Convert QuestionModel list to Map format
  List<Map<String, dynamic>> _convertQuestionsToMap(
      List<QuestionModel> questionsList) {
    return questionsList.map((q) {
      // Find the correct answer
      String correctAnswer = '';
      try {
        final correctOption =
            q.options.firstWhere((opt) => opt.isCorrect);
        correctAnswer = correctOption.optionText;
      } catch (e) {
        logger.w('No correct answer found for question ${q.id}');
      }

      return {
        'id': q.id,
        'question': q.questionText,
        'options': q.options.map((opt) => opt.optionText).toList(),
        'answer': correctAnswer,
        'difficulty': q.quesDeficulty,
        'category': q.quesCategory,
      };
    }).toList();
  }

  /// Refresh questions (when navigating back from quiz screen)
  void refreshQuestions() {
    _loadQuestions();
  }

  /// Go back to quiz selection
  void goBackToQuizSelection() {
    // Reset state
    currentIndex.value = 0;
    selectedOption.value = '';
    selectedOptions.clear();
    lastQuizId.value = 0;
    Get.back();
  }

  /// Select option safely
  void selectOption(String option) {
    selectedOption.value = option;

    // Ensure the list has enough elements
    while (selectedOptions.length <= currentIndex.value) {
      selectedOptions.add('');
    }
    selectedOptions[currentIndex.value] = option;
  }

  /// Move to next question or finish quiz
  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;

      // Safely restore previous selection or empty
      if (selectedOptions.length > currentIndex.value) {
        selectedOption.value = selectedOptions[currentIndex.value];
      } else {
        selectedOption.value = '';
      }
    } else {
      // Quiz finished, calculate correct answers
      int correctAnswers = getCorrectAnswersCount();
      int totalQuestions = questions.length;

      // Submit quiz result to API
      _submitQuizResult(correctAnswers, totalQuestions);
      // Get.toNamed(
      //     AppRoutes.getquizCongratulationScreen(),
      //     arguments: {
      //       'score': correctAnswers,
      //       'totalScore': totalQuestions,
      //     },
      //   );

      if (correctAnswers == totalQuestions) {
        // Pass score to congratulation screen
        Get.toNamed(
          AppRoutes.getquizCongratulationScreen(),
          arguments: {
            'score': correctAnswers,
            'totalScore': totalQuestions,
          },
        );
      } else {
        // Pass score to try again screen
        Get.toNamed(
          AppRoutes.gettryAginScreen(),
          arguments: {
            'score': '$correctAnswers/$totalQuestions',
          },
        );
      }
    }
  }

  /// Move to previous question safely
  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;

      // Safely restore previous selection or empty
      selectedOption.value = selectedOptions.length > currentIndex.value
          ? selectedOptions[currentIndex.value]
          : '';
    }
  }

  /// Check if option is correct for current question
  bool isCorrect(String option) {
    if (questions.isEmpty || currentIndex.value >= questions.length) {
      return false;
    }
    return option == questions[currentIndex.value]['answer'];
  }

  /// Get score
  int getCorrectAnswersCount() {
    int correctAnswers = 0;
    for (var i = 0; i < questions.length; i++) {
      if (selectedOptions.length > i &&
          selectedOptions[i] == questions[i]['answer']) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  /// Submit quiz result to API
  void _submitQuizResult(int correctAnswers, int totalQuestions) {
    try {
      // Get quiz ID from AppQuizController or lastQuizId
      int quizId = 0;
      try {
        final quizCtrl = Get.find<AppQuizController>();
        if (quizCtrl.quiz.value != null) {
          quizId = quizCtrl.quiz.value!.id;
        }
      } catch (e) {
        quizId = lastQuizId.value;
      }

      if (quizId == 0) {
        logger.w('Quiz ID not found, cannot submit result');
        return;
      }

      // Submit to API without waiting for response
      quizService.submitQuizResult(
        quizId: quizId,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
      ).then((response) {
        logger.i('Quiz result submitted successfully: $response');
      }).catchError((e) {
        logger.e('Error submitting quiz result: $e');
        // Don't show error to user, just log it
      });
    } catch (e) {
      logger.e('Error in _submitQuizResult: $e');
    }
  }
}
