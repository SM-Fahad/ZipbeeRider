import 'package:ZipBee_Driver/features/app_quzi/model/quiz_model.dart';
import 'package:ZipBee_Driver/features/app_quzi/model/question_model.dart';
import 'package:ZipBee_Driver/features/app_quzi/service/quiz_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AppQuizController extends GetxController {
  // Observables
  var quiz = Rx<QuizModel?>(null);
  var questions = <QuestionModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Services
  final quizService = QuizService();
  final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    fetchActiveQuiz();
  }

  /// Fetch active quiz from API
  Future<void> fetchActiveQuiz() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      logger.i('Fetching active quiz...');
      final quizData = await quizService.fetchActiveQuiz();

      quiz.value = quizData;
      logger.i('Quiz loaded successfully: ${quizData.title}');

      // Fetch questions for this quiz
      await fetchQuizQuestions(quizData.id);
    } catch (e) {
      errorMessage.value = e.toString();
      logger.e('Error fetching quiz: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reloadQuiz() async {
    quiz.value = null;
    questions.clear();
    errorMessage.value = '';
    await fetchActiveQuiz();
  }

  /// Fetch questions for the quiz
  Future<void> fetchQuizQuestions(int quizId) async {
    try {
      logger.i('Fetching questions for quiz: $quizId');
      final questionsList = await quizService.fetchQuizQuestions(quizId);

      questions.value = questionsList;
      logger.i(
        'Questions loaded successfully: ${questionsList.length} questions',
      );
    } catch (e) {
      logger.e('Error fetching questions: $e');
      // Don't override error message, but log the issue
    }
  }

  /// Get number of questions
  int getNumberOfQuestions() {
    return questions.length;
  }

  /// Get points for correct answer
  int getPointsPerCorrectAnswer() {
    return questions.length;
  }

  /// Get total possible points
  int getTotalPoints() {
    return getPointsPerCorrectAnswer() * getNumberOfQuestions();
  }
}
