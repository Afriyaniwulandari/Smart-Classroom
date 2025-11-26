import '../services/ai_grading_service.dart';

enum QuestionType { multipleChoice, matching, shortEssay }

class Question {
  final String id;
  final String questionText;
  final QuestionType type;
  final List<String> options; // For multiple choice and matching
  final List<String> correctAnswers; // For multiple choice (single), matching (pairs), essay (keywords)
  final int points;
  final String? hint; // AI hint for essays
  final EssayGradingCriteria? gradingCriteria; // For essay questions

  Question({
    required this.id,
    required this.questionText,
    required this.type,
    required this.options,
    required this.correctAnswers,
    required this.points,
    this.hint,
    this.gradingCriteria,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['questionText'],
      type: QuestionType.values[json['type']],
      options: List<String>.from(json['options'] ?? []),
      correctAnswers: List<String>.from(json['correctAnswers'] ?? []),
      points: json['points'] ?? 1,
      hint: json['hint'],
      gradingCriteria: json['gradingCriteria'] != null
          ? EssayGradingCriteria(
              keywordWeight: (json['gradingCriteria']['keywordWeight'] ?? 0.5).toDouble(),
              lengthWeight: (json['gradingCriteria']['lengthWeight'] ?? 0.2).toDouble(),
              coherenceWeight: (json['gradingCriteria']['coherenceWeight'] ?? 0.3).toDouble(),
              minLength: json['gradingCriteria']['minLength'] ?? 50,
              maxLength: json['gradingCriteria']['maxLength'] ?? 500,
              keywords: List<String>.from(json['gradingCriteria']['keywords'] ?? []),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'type': type.index,
      'options': options,
      'correctAnswers': correctAnswers,
      'points': points,
      'hint': hint,
      'gradingCriteria': gradingCriteria != null
          ? {
              'keywordWeight': gradingCriteria!.keywordWeight,
              'lengthWeight': gradingCriteria!.lengthWeight,
              'coherenceWeight': gradingCriteria!.coherenceWeight,
              'minLength': gradingCriteria!.minLength,
              'maxLength': gradingCriteria!.maxLength,
              'keywords': gradingCriteria!.keywords,
            }
          : null,
    };
  }

  Question copyWith({
    String? id,
    String? questionText,
    QuestionType? type,
    List<String>? options,
    List<String>? correctAnswers,
    int? points,
    String? hint,
    EssayGradingCriteria? gradingCriteria,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      points: points ?? this.points,
      hint: hint ?? this.hint,
      gradingCriteria: gradingCriteria ?? this.gradingCriteria,
    );
  }
}

class Quiz {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final List<Question> questions;
  final int timeLimitMinutes; // 0 means no time limit
  final DateTime createdAt;
  final String createdBy; // teacher ID

  Quiz({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimitMinutes,
    required this.createdAt,
    required this.createdBy,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      lessonId: json['lessonId'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimitMinutes': timeLimitMinutes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Quiz copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    List<Question>? questions,
    int? timeLimitMinutes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Quiz(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}