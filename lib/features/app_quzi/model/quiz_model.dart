class QuizModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final int timeLimit;
  final String difficulty;
  final bool shuffleQuestions;
  final bool isActive;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timeLimit,
    required this.difficulty,
    required this.shuffleQuestions,
    required this.isActive,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final quizOption = json['QuizOption'] as Map<String, dynamic>?;
    
    return QuizModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Quiz',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      timeLimit: quizOption?['timeLimit'] ?? 30,
      difficulty: quizOption?['difficulty'] ?? 'medium',
      shuffleQuestions: quizOption?['shuffleQuestions'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'QuizOption': {
        'timeLimit': timeLimit,
        'difficulty': difficulty,
        'shuffleQuestions': shuffleQuestions,
      },
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
