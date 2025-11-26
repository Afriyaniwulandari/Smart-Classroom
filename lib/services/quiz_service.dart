import '../models/quiz.dart';
import '../models/quiz_result.dart';
import 'ai_grading_service.dart';

class QuizService {
  final AiGradingService _aiGradingService = AiGradingService();

  // Mock data for development
  final List<Map<String, dynamic>> _mockQuizzes = [
    {
      'id': '1',
      'lessonId': '1',
      'title': 'Algebra Quiz',
      'description': 'Test your understanding of basic algebra concepts',
      'questions': [
        {
          'id': 'q1',
          'questionText': 'What is 2 + 2?',
          'type': 0, // multipleChoice
          'options': ['3', '4', '5', '6'],
          'correctAnswers': ['4'],
          'points': 1,
          'hint': null,
        },
        {
          'id': 'q2',
          'questionText': 'Solve for x: 2x = 10',
          'type': 0, // multipleChoice
          'options': ['x = 3', 'x = 5', 'x = 7', 'x = 10'],
          'correctAnswers': ['x = 5'],
          'points': 1,
          'hint': null,
        },
        {
          'id': 'q3',
          'questionText': 'Match the following terms with their definitions',
          'type': 1, // matching
          'options': ['Variable', 'Equation', 'Inequality', 'A letter representing a number', 'A mathematical statement with an equals sign', 'A mathematical statement with <, >, ≤, or ≥'],
          'correctAnswers': ['Variable-A letter representing a number', 'Equation-A mathematical statement with an equals sign', 'Inequality-A mathematical statement with <, >, ≤, or ≥'],
          'points': 2,
          'hint': null,
        },
        {
          'id': 'q4',
          'questionText': 'Explain why algebra is important in real life. Provide at least two examples.',
          'type': 2, // shortEssay
          'options': [],
          'correctAnswers': ['problem solving', 'budgeting', 'engineering', 'science'],
          'points': 3,
          'hint': 'Think about how algebra helps in everyday situations like managing money or solving practical problems.',
          'gradingCriteria': {
            'keywordWeight': 0.5,
            'lengthWeight': 0.2,
            'coherenceWeight': 0.3,
            'minLength': 50,
            'maxLength': 500,
            'keywords': ['problem solving', 'budgeting', 'engineering', 'science'],
          },
        },
      ],
      'timeLimitMinutes': 30,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'createdBy': '2',
    },
  ];

  final List<Map<String, dynamic>> _mockQuizResults = [];

  Future<List<Quiz>> getQuizzes(String lessonId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockQuizzes
        .where((q) => q['lessonId'] == lessonId)
        .map((q) => Quiz.fromJson(q))
        .toList();
  }

  Future<Quiz?> getQuiz(String quizId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final quizData = _mockQuizzes.firstWhere(
      (q) => q['id'] == quizId,
      orElse: () => {},
    );

    if (quizData.isEmpty) return null;
    return Quiz.fromJson(quizData);
  }

  Future<bool> createQuiz(Quiz quiz) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    _mockQuizzes.add(quiz.toJson());
    return true;
  }

  Future<bool> updateQuiz(Quiz quiz) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final quizIndex = _mockQuizzes.indexWhere((q) => q['id'] == quiz.id);
    if (quizIndex != -1) {
      _mockQuizzes[quizIndex] = quiz.toJson();
      return true;
    }
    return false;
  }

  Future<bool> deleteQuiz(String quizId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    _mockQuizzes.removeWhere((q) => q['id'] == quizId);
    return true;
  }

  Future<List<QuizResult>> getQuizResults(String studentId, {String? quizId}) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockQuizResults
        .where((r) => r['studentId'] == studentId && (quizId == null || r['quizId'] == quizId))
        .map((r) => QuizResult.fromJson(r))
        .toList();
  }

  Future<QuizResult?> getQuizResult(String quizId, String studentId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final resultData = _mockQuizResults.firstWhere(
      (r) => r['quizId'] == quizId && r['studentId'] == studentId,
      orElse: () => {},
    );

    if (resultData.isEmpty) return null;
    return QuizResult.fromJson(resultData);
  }

  Future<bool> startQuiz(String quizId, String studentId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if student already has a result for this quiz
    final existingResult = _mockQuizResults.firstWhere(
      (r) => r['quizId'] == quizId && r['studentId'] == studentId,
      orElse: () => {},
    );

    if (existingResult.isNotEmpty) {
      // Update started time if not completed
      final resultIndex = _mockQuizResults.indexOf(existingResult);
      if (!existingResult['isCompleted']) {
        _mockQuizResults[resultIndex]['startedAt'] = DateTime.now().toIso8601String();
      }
      return true;
    }

    // Create new quiz result
    final quiz = await getQuiz(quizId);
    if (quiz == null) return false;

    final newResult = {
      'id': '${quizId}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      'quizId': quizId,
      'studentId': studentId,
      'answers': [],
      'totalScore': 0,
      'maxScore': quiz.questions.fold(0, (sum, q) => sum + q.points),
      'percentage': 0.0,
      'startedAt': DateTime.now().toIso8601String(),
      'completedAt': null,
      'timeTakenMinutes': 0,
      'isCompleted': false,
      'certificateUrl': null,
    };

    _mockQuizResults.add(newResult);
    return true;
  }

  Future<bool> submitQuizAnswer(String quizId, String studentId, String questionId, List<String> studentAnswers) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final resultIndex = _mockQuizResults.indexWhere(
      (r) => r['quizId'] == quizId && r['studentId'] == studentId,
    );

    if (resultIndex == -1) return false;

    final answers = _mockQuizResults[resultIndex]['answers'] as List;
    final existingAnswerIndex = answers.indexWhere((a) => a['questionId'] == questionId);

    final quiz = await getQuiz(quizId);
    if (quiz == null) return false;

    final question = quiz.questions.firstWhere((q) => q.id == questionId);

    EssayGradingResult? aiGradingResult;
    bool isCorrect = false;
    int pointsEarned = 0;

    if (question.type == QuestionType.shortEssay) {
      // Use AI grading for essays
      final criteria = question.gradingCriteria ?? EssayGradingCriteria.defaultCriteria(question.correctAnswers);
      aiGradingResult = await _aiGradingService.gradeEssay(studentAnswers.join(' '), criteria);
      isCorrect = aiGradingResult.totalScore >= 0.6; // Consider passing if score >= 60%
      pointsEarned = (aiGradingResult.totalScore * question.points).round();
    } else {
      // Use traditional checking for other question types
      isCorrect = _checkAnswer(question, studentAnswers);
      pointsEarned = isCorrect ? question.points : 0;
    }

    final answerData = {
      'questionId': questionId,
      'answers': studentAnswers,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'aiGradingResult': aiGradingResult != null
          ? {
              'totalScore': aiGradingResult.totalScore,
              'keywordScore': aiGradingResult.keywordScore,
              'lengthScore': aiGradingResult.lengthScore,
              'coherenceScore': aiGradingResult.coherenceScore,
              'feedback': aiGradingResult.feedback,
              'strengths': aiGradingResult.strengths,
              'improvements': aiGradingResult.improvements,
            }
          : null,
    };

    if (existingAnswerIndex != -1) {
      answers[existingAnswerIndex] = answerData;
    } else {
      answers.add(answerData);
    }

    return true;
  }

  Future<QuizResult?> completeQuiz(String quizId, String studentId, int timeTakenMinutes) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final resultIndex = _mockQuizResults.indexWhere(
      (r) => r['quizId'] == quizId && r['studentId'] == studentId,
    );

    if (resultIndex == -1) return null;

    final result = _mockQuizResults[resultIndex];
    final answers = result['answers'] as List;

    int totalScore = 0;
    for (var answer in answers) {
      totalScore += answer['pointsEarned'] as int;
    }

    final maxScore = result['maxScore'] as int;
    final percentage = maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0;

    result['totalScore'] = totalScore;
    result['percentage'] = percentage;
    result['completedAt'] = DateTime.now().toIso8601String();
    result['timeTakenMinutes'] = timeTakenMinutes;
    result['isCompleted'] = true;

    // Generate certificate if passed (e.g., 60% or higher)
    if (percentage >= 60.0) {
      result['certificateUrl'] = 'https://example.com/certificates/${result['id']}';
    }

    return QuizResult.fromJson(result);
  }

  bool _checkAnswer(Question question, List<String> studentAnswers) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return studentAnswers.length == 1 && question.correctAnswers.contains(studentAnswers[0]);
      case QuestionType.matching:
        // For matching, check if all pairs are correct
        if (studentAnswers.length != question.correctAnswers.length) return false;
        for (var answer in studentAnswers) {
          if (!question.correctAnswers.contains(answer)) return false;
        }
        return true;
      default:
        throw UnimplementedError('Unsupported question type for traditional checking: ${question.type}');
    }
  }

  Future<String?> generateCertificate(String quizResultId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, this would generate a PDF certificate
    return 'https://example.com/certificates/$quizResultId';
  }
}