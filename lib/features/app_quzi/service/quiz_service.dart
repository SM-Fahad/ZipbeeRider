import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/app_quzi/model/quiz_model.dart';
import 'package:ZipBee_Driver/features/app_quzi/model/question_model.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class QuizService {
  final String baseUrl = ApiEndPoint.baseUrl;
  final logger = Logger();

  /// Fetch active quiz from API
  Future<QuizModel> fetchActiveQuiz() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/quizzes/active');

      logger.i('Fetching active quiz from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      logger.i('Quiz response status: ${response.statusCode}');
      logger.i('Quiz response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['success'] == true && json['data'] != null) {
          return QuizModel.fromJson(json['data'] as Map<String, dynamic>);
        } else {
          throw Exception(json['message'] ?? 'Failed to load quiz');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load quiz: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching quiz: $e');
      throw Exception('Error fetching quiz: $e');
    }
  }

  /// Fetch questions for a quiz
  Future<List<QuestionModel>> fetchQuizQuestions(int quizId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/questions/$quizId');

      logger.i('Fetching quiz questions from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      logger.i('Questions response status: ${response.statusCode}');
      logger.i('Questions response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['success'] == true && json['data'] != null) {
          final List<dynamic> questionsList = json['data'] ?? [];
          return questionsList
              .map((item) =>
                  QuestionModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(json['message'] ?? 'Failed to load questions');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching questions: $e');
      throw Exception('Error fetching questions: $e');
    }
  }

  /// Submit quiz results to API
  Future<Map<String, dynamic>> submitQuizResult({
    required int quizId,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/questions/$quizId');

      final payload = {
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'score': ((correctAnswers / totalQuestions) * 100).toInt(),
      };

      logger.i('Submitting quiz result to: $url');
      logger.i('Payload: $payload');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      logger.i('Submit quiz response status: ${response.statusCode}');
      logger.i('Submit quiz response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        logger.i('Quiz result submitted successfully');
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to submit quiz result');
      }
    } catch (e) {
      logger.e('Error submitting quiz result: $e');
      throw Exception('Error submitting quiz result: $e');
    }
  }
}
