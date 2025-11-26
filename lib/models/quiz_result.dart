import '../services/ai_grading_service.dart';

class StudentAnswer {
  final String questionId;
  final List<String> answers; // For multiple choice (single answer), matching (pairs), essay (text)
  final bool isCorrect; // For auto-graded questions
  final int pointsEarned;
  final EssayGradingResult? aiGradingResult; // For essay questions

  StudentAnswer({
    required this.questionId,
    required this.answers,
    required this.isCorrect,
    required this.pointsEarned,
    this.aiGradingResult,
  });

  factory StudentAnswer.fromJson(Map<String, dynamic> json) {
    return StudentAnswer(
      questionId: json['questionId'],
      answers: List<String>.from(json['answers'] ?? []),
      isCorrect: json['isCorrect'] ?? false,
      pointsEarned: json['pointsEarned'] ?? 0,
      aiGradingResult: json['aiGradingResult'] != null
          ? EssayGradingResult(
              totalScore: (json['aiGradingResult']['totalScore'] ?? 0).toDouble(),
              keywordScore: (json['aiGradingResult']['keywordScore'] ?? 0).toDouble(),
              lengthScore: (json['aiGradingResult']['lengthScore'] ?? 0).toDouble(),
              coherenceScore: (json['aiGradingResult']['coherenceScore'] ?? 0).toDouble(),
              feedback: json['aiGradingResult']['feedback'] ?? '',
              strengths: List<String>.from(json['aiGradingResult']['strengths'] ?? []),
              improvements: List<String>.from(json['aiGradingResult']['improvements'] ?? []),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answers': answers,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'aiGradingResult': aiGradingResult != null
          ? {
              'totalScore': aiGradingResult!.totalScore,
              'keywordScore': aiGradingResult!.keywordScore,
              'lengthScore': aiGradingResult!.lengthScore,
              'coherenceScore': aiGradingResult!.coherenceScore,
              'feedback': aiGradingResult!.feedback,
              'strengths': aiGradingResult!.strengths,
              'improvements': aiGradingResult!.improvements,
            }
          : null,
    };
  }
}

class QuizResult {
  final String id;
  final String quizId;
  final String studentId;
  final List<StudentAnswer> answers;
  final int totalScore;
  final int maxScore;
  final double percentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int timeTakenMinutes; // Actual time taken
  final bool isCompleted;
  final String? certificateUrl; // For completed quizzes

  QuizResult({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.answers,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.startedAt,
    this.completedAt,
    required this.timeTakenMinutes,
    this.isCompleted = false,
    this.certificateUrl,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      quizId: json['quizId'],
      studentId: json['studentId'],
      answers: (json['answers'] as List<dynamic>?)
          ?.map((a) => StudentAnswer.fromJson(a))
          .toList() ?? [],
      totalScore: json['totalScore'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      timeTakenMinutes: json['timeTakenMinutes'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      certificateUrl: json['certificateUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'studentId': studentId,
      'answers': answers.map((a) => a.toJson()).toList(),
      'totalScore': totalScore,
      'maxScore': maxScore,
      'percentage': percentage,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'timeTakenMinutes': timeTakenMinutes,
      'isCompleted': isCompleted,
      'certificateUrl': certificateUrl,
    };
  }

  QuizResult copyWith({
    String? id,
    String? quizId,
    String? studentId,
    List<StudentAnswer>? answers,
    int? totalScore,
    int? maxScore,
    double? percentage,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeTakenMinutes,
    bool? isCompleted,
    String? certificateUrl,
  }) {
    return QuizResult(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      studentId: studentId ?? this.studentId,
      answers: answers ?? this.answers,
      totalScore: totalScore ?? this.totalScore,
      maxScore: maxScore ?? this.maxScore,
      percentage: percentage ?? this.percentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeTakenMinutes: timeTakenMinutes ?? this.timeTakenMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }
}