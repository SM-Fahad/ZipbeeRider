class QuestionOption {
  final int id;
  final int questionId;
  final String optionText;
  final bool isCorrect;

  QuestionOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] ?? 0,
      questionId: json['questionId'] ?? 0,
      optionText: json['option_text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'option_text': optionText,
      'is_correct': isCorrect,
    };
  }
}

class QuestionModel {
  final int id;
  final int quizId;
  final String quesType;
  final String quesCategory;
  final String quesDeficulty;
  final String questionText;
  final List<QuestionOption> options;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.quesType,
    required this.quesCategory,
    required this.quesDeficulty,
    required this.questionText,
    required this.options,
    required this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsList = (json['options'] as List<dynamic>?)
        ?.map((opt) => QuestionOption.fromJson(opt as Map<String, dynamic>))
        .toList() ??
        [];

    return QuestionModel(
      id: json['id'] ?? 0,
      quizId: json['quizId'] ?? 0,
      quesType: json['quesType'] ?? 'MULTIPLE',
      quesCategory: json['quesCategory'] ?? '',
      quesDeficulty: json['quesDeficulty'] ?? 'EASY',
      questionText: json['question_text'] ?? '',
      options: optionsList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'quesType': quesType,
      'quesCategory': quesCategory,
      'quesDeficulty': quesDeficulty,
      'question_text': questionText,
      'options': options.map((opt) => opt.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
